import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result type
// ─────────────────────────────────────────────────────────────────────────────

enum BiometricResult {
  /// Authentication succeeded.
  success,

  /// The user dismissed the prompt or it timed out.
  failed,

  /// Device has no biometric hardware or it is not set up in the OS.
  notAvailable,

  /// No biometrics have been enrolled (hardware present but not configured).
  notEnrolled,

  /// Biometrics are temporarily or permanently locked out by the OS.
  lockedOut,
}

// ─────────────────────────────────────────────────────────────────────────────
// BiometricService
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [LocalAuthentication] for Face ID / Touch ID / Fingerprint auth.
///
/// All methods are safe to call when biometrics are unavailable; they return
/// the appropriate [BiometricResult] rather than throwing.
///
/// Inject a custom [LocalAuthentication] in tests:
/// ```dart
/// BiometricService(auth: mockLocalAuth);
/// ```
class BiometricService {
  final LocalAuthentication _auth;

  /// Creates a [BiometricService].
  /// When [auth] is omitted a default [LocalAuthentication] is used.
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  // ── Capability checks ──────────────────────────────────────────────────────

  /// True if the device supports biometric or device-credential verification.
  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// The biometric types enrolled on this device.
  Future<List<BiometricType>> enrolledTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Human-readable name for the strongest available biometric.
  /// e.g. "Face ID", "Touch ID", "Fingerprint", "Biometrics".
  Future<String> biometricLabel() async {
    final types = await enrolledTypes();
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Touch ID';
    if (types.contains(BiometricType.iris)) return 'Iris';
    return 'Biometrics';
  }

  /// Icon name for the primary biometric: "face" or "fingerprint".
  Future<String> biometricIconName() async {
    final types = await enrolledTypes();
    if (types.contains(BiometricType.face)) return 'face';
    return 'fingerprint';
  }

  // ── Authentication ─────────────────────────────────────────────────────────

  /// Prompt the OS biometric / device-credential sheet.
  ///
  /// Returns [BiometricResult.success] on approval, or an appropriate failure
  /// variant without throwing. [reason] surfaces in the system prompt.
  Future<BiometricResult> authenticate({
    String reason = 'Unlock Fearless Inventory',
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // Allow device PIN/pattern as OS-level fallback inside the system
          // prompt — distinct from the app PIN pad.
          biometricOnly: false,
          // Keep the sheet alive if the user briefly leaves the app.
          stickyAuth: true,
          // Signals to the OS that this guards sensitive data.
          sensitiveTransaction: true,
        ),
      );
      return success ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notAvailable:
          return BiometricResult.notAvailable;
        case auth_error.notEnrolled:
          return BiometricResult.notEnrolled;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return BiometricResult.lockedOut;
        default:
          return BiometricResult.failed;
      }
    } catch (_) {
      return BiometricResult.failed;
    }
  }
}
