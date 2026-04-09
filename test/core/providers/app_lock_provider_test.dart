import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/app_lock_provider.dart';
import 'package:fearless_inventory/core/services/biometric_service.dart';
import 'package:fearless_inventory/core/services/pin_service.dart';

import '../services/pin_service_test.dart' show FakeSecureStorage;

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
  });

  group('AppLockState', () {
    test('copyWith preserves unspecified fields', () {
      const s = AppLockState(
        isLoading: false,
        isLocked: true,
        hasPin: true,
        biometricEnabled: true,
        biometricAvailable: true,
      );
      final next = s.copyWith(isLocked: false);
      expect(next.isLoading, isFalse);
      expect(next.isLocked, isFalse);
      expect(next.hasPin, isTrue);
      expect(next.biometricEnabled, isTrue);
      expect(next.biometricAvailable, isTrue);
    });
  });

  group('AppLockNotifier', () {
    late FakeSecureStorage storage;
    late PinService pinService;
    late MockLocalAuthentication mockLocalAuth;
    late BiometricService biometricService;

    setUp(() {
      storage = FakeSecureStorage();
      pinService = PinService(storage);
      mockLocalAuth = MockLocalAuthentication();
      when(() => mockLocalAuth.canCheckBiometrics)
          .thenAnswer((_) async => false);
      when(() => mockLocalAuth.isDeviceSupported())
          .thenAnswer((_) async => true);
      biometricService = BiometricService(auth: mockLocalAuth);
    });

    Future<void> waitForInit(ProviderContainer c) async {
      for (var i = 0; i < 200; i++) {
        if (!c.read(appLockProvider).isLoading) return;
        await Future<void>.delayed(Duration.zero);
      }
      fail('AppLockNotifier did not finish loading');
    }

    test('without PIN: unlocked after init', () async {
      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          biometricServiceProvider.overrideWithValue(biometricService),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLockProvider.notifier);
      await waitForInit(container);

      final s = container.read(appLockProvider);
      expect(s.hasPin, isFalse);
      expect(s.isLocked, isFalse);
      expect(s.biometricAvailable, isTrue);
    });

    test('with PIN: locked after init; unlock and lock', () async {
      await pinService.setPin('123456');

      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          biometricServiceProvider.overrideWithValue(biometricService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockProvider.notifier);
      await waitForInit(container);

      expect(container.read(appLockProvider).hasPin, isTrue);
      expect(container.read(appLockProvider).isLocked, isTrue);

      notifier.unlock();
      expect(container.read(appLockProvider).isLocked, isFalse);

      notifier.lock();
      expect(container.read(appLockProvider).isLocked, isTrue);
    });

    test('lock is no-op when there is no PIN', () async {
      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          biometricServiceProvider.overrideWithValue(biometricService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockProvider.notifier);
      await waitForInit(container);

      expect(container.read(appLockProvider).isLocked, isFalse);
      notifier.lock();
      expect(container.read(appLockProvider).isLocked, isFalse);
    });
  });
}
