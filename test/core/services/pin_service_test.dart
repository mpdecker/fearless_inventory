// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/pin_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// In-memory FlutterSecureStorage fake
// ─────────────────────────────────────────────────────────────────────────────

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final _data = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _data.remove(key);
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late FakeSecureStorage storage;
  late PinService sut;

  setUp(() {
    storage = FakeSecureStorage();
    sut = PinService(storage);
  });

  // ── hasPin ─────────────────────────────────────────────────────────────────

  group('hasPin', () {
    test('returns false when storage is empty', () async {
      expect(await sut.hasPin(), isFalse);
    });

    test('returns true after setPin is called', () async {
      await sut.setPin('123456');
      expect(await sut.hasPin(), isTrue);
    });

    test('returns false after clearPin is called', () async {
      await sut.setPin('123456');
      await sut.clearPin();
      expect(await sut.hasPin(), isFalse);
    });
  });

  // ── verifyPin — correct PIN ────────────────────────────────────────────────

  group('verifyPin — correct', () {
    const pin = '741852';

    setUp(() async => sut.setPin(pin));

    test('isCorrect for the right PIN', () async {
      final result = await sut.verifyPin(pin);
      expect(result.isCorrect, isTrue);
    });

    test('correct result is not incorrect or lockedOut', () async {
      final result = await sut.verifyPin(pin);
      expect(result.isIncorrect, isFalse);
      expect(result.isLockedOut, isFalse);
    });
  });

  // ── verifyPin — wrong PIN ──────────────────────────────────────────────────

  group('verifyPin — wrong', () {
    const correctPin = '111111';
    const wrongPin = '999999';

    setUp(() async => sut.setPin(correctPin));

    test('isIncorrect for the wrong PIN', () async {
      final result = await sut.verifyPin(wrongPin);
      expect(result.isIncorrect, isTrue);
    });

    test('remainingAttempts counts down from maxFailedAttempts - 1', () async {
      for (int expected = PinService.maxFailedAttempts - 1;
          expected >= 1;
          expected--) {
        final result = await sut.verifyPin(wrongPin);
        expect(result.remainingAttempts, equals(expected));
      }
    });

    test('returns lockedOut after exactly maxFailedAttempts wrong tries',
        () async {
      for (int i = 0; i < PinService.maxFailedAttempts; i++) {
        await sut.verifyPin(wrongPin);
      }
      final result = await sut.verifyPin(wrongPin);
      expect(result.isLockedOut, isTrue);
    });

    test('lockoutRemaining is positive when locked out', () async {
      for (int i = 0; i < PinService.maxFailedAttempts; i++) {
        await sut.verifyPin(wrongPin);
      }
      final result = await sut.verifyPin(wrongPin);
      expect(result.lockoutRemaining!.inSeconds, isPositive);
    });

    test('correct PIN after failures resets the counter', () async {
      // Two failures.
      await sut.verifyPin(wrongPin);
      await sut.verifyPin(wrongPin);
      // One success resets the counter.
      await sut.verifyPin(correctPin);
      // Next failure should show max-1 remaining again.
      final result = await sut.verifyPin(wrongPin);
      expect(result.remainingAttempts,
          equals(PinService.maxFailedAttempts - 1));
    });
  });

  // ── verifyPin — no PIN ────────────────────────────────────────────────────

  group('verifyPin — no PIN configured', () {
    test('returns isNoPin when no PIN has been set', () async {
      final result = await sut.verifyPin('123456');
      expect(result.isNoPin, isTrue);
    });

    test('returns isNoPin after clearPin', () async {
      await sut.setPin('123456');
      await sut.clearPin();
      final result = await sut.verifyPin('123456');
      expect(result.isNoPin, isTrue);
    });
  });

  // ── Salt uniqueness ────────────────────────────────────────────────────────

  group('salt uniqueness', () {
    test('re-setting the same PIN still verifies correctly', () async {
      await sut.setPin('246810');
      await sut.setPin('246810'); // New salt generated each time.
      final result = await sut.verifyPin('246810');
      expect(result.isCorrect, isTrue);
    });

    test('old PIN does not verify after setPin is called again', () async {
      await sut.setPin('111111');
      await sut.setPin('222222'); // Replace with a new PIN.
      // Old PIN should now fail.
      final result = await sut.verifyPin('111111');
      expect(result.isCorrect, isFalse);
    });
  });

  // ── Biometric preference ───────────────────────────────────────────────────

  group('biometric preference', () {
    test('disabled by default', () async {
      expect(await sut.isBiometricEnabled(), isFalse);
    });

    test('enabled after setBiometricEnabled(true)', () async {
      await sut.setBiometricEnabled(enabled: true);
      expect(await sut.isBiometricEnabled(), isTrue);
    });

    test('disabled after setBiometricEnabled(false)', () async {
      await sut.setBiometricEnabled(enabled: true);
      await sut.setBiometricEnabled(enabled: false);
      expect(await sut.isBiometricEnabled(), isFalse);
    });

    test('cleared by clearPin', () async {
      await sut.setPin('123456');
      await sut.setBiometricEnabled(enabled: true);
      await sut.clearPin();
      expect(await sut.isBiometricEnabled(), isFalse);
    });
  });

  // ── pinLength constant ────────────────────────────────────────────────────

  test('pinLength is 6', () {
    expect(PinService.pinLength, equals(6));
  });

  // ── maxFailedAttempts constant ────────────────────────────────────────────

  test('maxFailedAttempts is 5', () {
    expect(PinService.maxFailedAttempts, equals(5));
  });
}
