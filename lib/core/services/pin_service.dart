import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_secure_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result types
// ─────────────────────────────────────────────────────────────────────────────

/// Result of a PIN verification attempt.
///
/// Use the [isCorrect], [isIncorrect], [isNoPin], [isLockedOut] getters
/// for quick checks, or switch on the concrete subtypes.
sealed class PinVerifyResult {
  const PinVerifyResult();

  // ── Factory constructors ──────────────────────────────────────────────────

  /// The PIN matched.
  static const correct = PinCorrectResult();

  /// No PIN has been configured yet.
  static const noPin = PinNoPinResult();

  /// The PIN did not match. [remainingAttempts] before lockout.
  static PinVerifyResult incorrect(int remainingAttempts) =>
      PinIncorrectResult(remainingAttempts);

  /// Too many failures; locked out for [remaining] duration.
  static PinVerifyResult lockedOut(Duration remaining) =>
      PinLockedOutResult(remaining);

  // ── Convenience predicates ────────────────────────────────────────────────

  bool get isCorrect => this is PinCorrectResult;
  bool get isNoPin => this is PinNoPinResult;
  bool get isIncorrect => this is PinIncorrectResult;
  bool get isLockedOut => this is PinLockedOutResult;

  /// Remaining attempts before lockout, or null if not applicable.
  int? get remainingAttempts =>
      this is PinIncorrectResult ? (this as PinIncorrectResult).attemptsLeft : null;

  /// Lockout duration remaining, or null if not applicable.
  Duration? get lockoutRemaining =>
      this is PinLockedOutResult ? (this as PinLockedOutResult).remaining : null;
}

final class PinCorrectResult extends PinVerifyResult {
  const PinCorrectResult();
}

final class PinNoPinResult extends PinVerifyResult {
  const PinNoPinResult();
}

final class PinIncorrectResult extends PinVerifyResult {
  final int attemptsLeft;
  const PinIncorrectResult(this.attemptsLeft);
}

final class PinLockedOutResult extends PinVerifyResult {
  final Duration remaining;
  const PinLockedOutResult(this.remaining);
}

// ─────────────────────────────────────────────────────────────────────────────
// PinService
// ─────────────────────────────────────────────────────────────────────────────

/// Manages the app-lock PIN.
///
/// The raw PIN is **never stored**. Instead we store:
///   - A 32-byte cryptographically random salt (base64url)
///   - SHA-256(salt + ":" + pin)
///
/// Security properties:
///   - Brute-force is throttled: [maxFailedAttempts] consecutive wrong attempts
///     triggers a [lockoutDuration] lockout, persisted to secure storage so
///     it survives app restarts.
///   - The salt is unique per PIN-set so rainbow tables are useless.
///   - All state lives in the OS keystore / keychain via [FlutterSecureStorage].
class PinService {
  // Storage keys ─────────────────────────────────────────────────────────────
  static const _kHash = 'fearless_pin_hash_v1';
  static const _kSalt = 'fearless_pin_salt_v1';
  static const _kBiometric = 'fearless_biometric_enabled_v1';
  static const _kFailedAttempts = 'fearless_pin_failed_attempts_v1';
  static const _kLockoutUntil = 'fearless_pin_lockout_until_v1';

  // Policy constants ─────────────────────────────────────────────────────────

  /// Number of consecutive wrong PINs before lockout.
  static const int maxFailedAttempts = 5;

  /// How long the app stays locked after too many bad attempts.
  static const Duration lockoutDuration = Duration(minutes: 5);

  /// Required PIN length.
  static const int pinLength = 6;

  final FlutterSecureStorage _storage;

  /// Creates a [PinService] backed by [storage].
  /// Defaults to the app-wide [appSecureStorage] singleton.
  const PinService([FlutterSecureStorage? storage])
      : _storage = storage ?? appSecureStorage;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Whether a PIN has already been configured on this device.
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _kHash);
    return hash != null && hash.isNotEmpty;
  }

  /// Persist a new [pin].  Previous PIN (if any) is overwritten.
  ///
  /// Resets failed-attempt counter and any active lockout.
  Future<void> setPin(String pin) async {
    assert(pin.length == pinLength, 'PIN must be exactly $pinLength digits');
    assert(RegExp(r'^\d+$').hasMatch(pin), 'PIN must be numeric');

    final salt = _generateSalt();
    final hash = _computeHash(salt, pin);

    await _storage.write(key: _kSalt, value: salt);
    await _storage.write(key: _kHash, value: hash);
    await _resetFailedAttempts();
  }

  /// Verify [pin] against the stored hash.
  ///
  /// Returns [PinVerifyResult.correct] on success,
  /// [PinVerifyResult.incorrect] with remaining attempts on failure,
  /// or [PinVerifyResult.lockedOut] if currently locked out.
  Future<PinVerifyResult> verifyPin(String pin) async {
    final lockout = await _checkLockout();
    if (lockout != null) return lockout;

    final salt = await _storage.read(key: _kSalt);
    final storedHash = await _storage.read(key: _kHash);
    if (salt == null || storedHash == null) return PinVerifyResult.noPin;

    final hash = _computeHash(salt, pin);
    if (hash == storedHash) {
      await _resetFailedAttempts();
      return PinVerifyResult.correct;
    }
    return _recordFailedAttempt();
  }

  /// Whether the user has opted in to biometric unlock.
  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _kBiometric);
    return val == 'true';
  }

  /// Enable or disable biometric unlock preference.
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.write(key: _kBiometric, value: enabled.toString());
  }

  /// Wipe all PIN-related data from secure storage.
  /// Used on "Clear All Data" and account deletion.
  Future<void> clearPin() async {
    await _storage.delete(key: _kHash);
    await _storage.delete(key: _kSalt);
    await _storage.delete(key: _kBiometric);
    await _resetFailedAttempts();
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _computeHash(String salt, String pin) {
    final input = utf8.encode('$salt:$pin');
    return sha256.convert(input).toString();
  }

  Future<void> _resetFailedAttempts() async {
    await _storage.delete(key: _kFailedAttempts);
    await _storage.delete(key: _kLockoutUntil);
  }

  /// Returns a [PinVerifyResult.lockedOut] if we are still in a lockout window,
  /// null otherwise (and clears expired lockout from storage).
  Future<PinVerifyResult?> _checkLockout() async {
    final raw = await _storage.read(key: _kLockoutUntil);
    if (raw == null) return null;

    final until = DateTime.tryParse(raw);
    if (until == null) return null;

    final now = DateTime.now();
    if (now.isBefore(until)) {
      return PinVerifyResult.lockedOut(until.difference(now));
    }

    // Lockout has expired — clear it.
    await _resetFailedAttempts();
    return null;
  }

  Future<PinVerifyResult> _recordFailedAttempt() async {
    final raw = await _storage.read(key: _kFailedAttempts);
    final previous = int.tryParse(raw ?? '0') ?? 0;
    final count = previous + 1;

    if (count >= maxFailedAttempts) {
      final until = DateTime.now().add(lockoutDuration);
      await _storage.write(
        key: _kLockoutUntil,
        value: until.toIso8601String(),
      );
      await _storage.delete(key: _kFailedAttempts);
      return PinVerifyResult.lockedOut(lockoutDuration);
    }

    await _storage.write(key: _kFailedAttempts, value: count.toString());
    return PinVerifyResult.incorrect(maxFailedAttempts - count);
  }
}
