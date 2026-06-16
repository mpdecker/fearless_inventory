import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/services/biometric_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock
// ─────────────────────────────────────────────────────────────────────────────

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
  });

  late MockLocalAuthentication mockAuth;
  late BiometricService sut;

  setUp(() {
    mockAuth = MockLocalAuthentication();
    sut = BiometricService(auth: mockAuth);
  });

  // ── isAvailable ────────────────────────────────────────────────────────────

  group('isAvailable', () {
    test('returns true when canCheckBiometrics is true', () async {
      when(() => mockAuth.canCheckBiometrics)
          .thenAnswer((_) async => true);
      when(() => mockAuth.isDeviceSupported())
          .thenAnswer((_) async => false);

      expect(await sut.isAvailable(), isTrue);
    });

    test('returns true when isDeviceSupported is true', () async {
      when(() => mockAuth.canCheckBiometrics)
          .thenAnswer((_) async => false);
      when(() => mockAuth.isDeviceSupported())
          .thenAnswer((_) async => true);

      expect(await sut.isAvailable(), isTrue);
    });

    test('returns false when both are false', () async {
      when(() => mockAuth.canCheckBiometrics)
          .thenAnswer((_) async => false);
      when(() => mockAuth.isDeviceSupported())
          .thenAnswer((_) async => false);

      expect(await sut.isAvailable(), isFalse);
    });

    test('returns false and does not throw when platform throws', () async {
      when(() => mockAuth.canCheckBiometrics)
          .thenThrow(PlatformException(code: 'unknown'));

      expect(await sut.isAvailable(), isFalse);
    });
  });

  // ── enrolledTypes / biometricLabel ─────────────────────────────────────────

  group('biometricLabel', () {
    test('returns "Face ID" when face type is enrolled', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.face]);

      expect(await sut.biometricLabel(), equals('Face ID'));
    });

    test('returns "Touch ID" when fingerprint type is enrolled', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);

      expect(await sut.biometricLabel(), equals('Touch ID'));
    });

    test('returns "Biometrics" when no specific type is found', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => []);

      expect(await sut.biometricLabel(), equals('Biometrics'));
    });

    test('prefers face over fingerprint when both are present', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer(
              (_) async => [BiometricType.face, BiometricType.fingerprint]);

      expect(await sut.biometricLabel(), equals('Face ID'));
    });

    test('returns "Biometrics" when getAvailableBiometrics throws', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenThrow(PlatformException(code: 'error'));

      expect(await sut.biometricLabel(), equals('Biometrics'));
    });
  });

  // ── biometricIconName ────────────────────────────────────────────────────

  group('biometricIconName', () {
    test('returns "face" when face ID is enrolled', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.face]);

      expect(await sut.biometricIconName(), equals('face'));
    });

    test('returns "fingerprint" when only fingerprint is enrolled', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);

      expect(await sut.biometricIconName(), equals('fingerprint'));
    });

    test('returns "fingerprint" when nothing is enrolled', () async {
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => []);

      expect(await sut.biometricIconName(), equals('fingerprint'));
    });
  });

  // ── authenticate ─────────────────────────────────────────────────────────

  group('authenticate', () {
    test('returns success when authenticate returns true', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.success));
    });

    test('returns failed when authenticate returns false', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => false);

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.failed));
    });

    test('returns notAvailable when platform throws notAvailable', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(PlatformException(code: auth_error.notAvailable));

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.notAvailable));
    });

    test('returns notEnrolled when platform throws notEnrolled', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(PlatformException(code: auth_error.notEnrolled));

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.notEnrolled));
    });

    test('returns lockedOut when platform throws lockedOut', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(PlatformException(code: auth_error.lockedOut));

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.lockedOut));
    });

    test('returns lockedOut when platform throws permanentlyLockedOut',
        () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(
              PlatformException(code: auth_error.permanentlyLockedOut));

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.lockedOut));
    });

    test('returns failed for an unknown PlatformException code', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(PlatformException(code: 'some_other_error'));

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.failed));
    });

    test('returns failed when an unexpected exception is thrown', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(Exception('Unexpected'));

      final result = await sut.authenticate();
      expect(result, equals(BiometricResult.failed));
    });
  });
}
