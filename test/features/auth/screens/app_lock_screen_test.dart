import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/app_lock_provider.dart';
import 'package:fearless_inventory/core/services/biometric_service.dart';
import 'package:fearless_inventory/core/services/pin_service.dart';
import 'package:fearless_inventory/features/auth/screens/app_lock_screen.dart';
import 'package:fearless_inventory/features/auth/widgets/pin_pad.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockPinService extends Mock implements PinService {}

class MockBiometricService extends Mock implements BiometricService {}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildLockScreen({
  required PinService pinService,
  required BiometricService biometricService,
  AppLockState? initialState,
}) {
  final lockState = initialState ??
      const AppLockState(
        isLoading: false,
        isLocked: true,
        hasPin: true,
        biometricEnabled: false,
        biometricAvailable: false,
      );

  return ProviderScope(
    overrides: [
      pinServiceProvider.overrideWithValue(pinService),
      biometricServiceProvider.overrideWithValue(biometricService),
      appLockProvider.overrideWith(() => _FixedAppLockNotifier(lockState)),
    ],
    child: const MaterialApp(home: AppLockScreen()),
  );
}

/// A notifier that holds a fixed state — used to bypass async initialisation
/// in widget tests.
class _FixedAppLockNotifier extends AppLockNotifier {
  final AppLockState _state;
  _FixedAppLockNotifier(this._state);

  @override
  AppLockState build() => _state;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockPinService mockPinService;
  late MockBiometricService mockBiometricService;

  setUp(() {
    mockPinService = MockPinService();
    mockBiometricService = MockBiometricService();

    // Default stubs so initState doesn't throw.
    when(() => mockBiometricService.isAvailable())
        .thenAnswer((_) async => false);
    when(() => mockBiometricService.biometricLabel())
        .thenAnswer((_) async => 'Biometrics');
    when(() => mockBiometricService.biometricIconName())
        .thenAnswer((_) async => 'fingerprint');
  });

  // ── Layout ─────────────────────────────────────────────────────────────────

  group('layout', () {
    testWidgets('renders app name and PIN pad', (tester) async {
      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pump();

      expect(find.text('Fearless Inventory'), findsOneWidget);
      expect(find.byType(PinDots), findsOneWidget);
      expect(find.byType(PinPad), findsOneWidget);
    });

    testWidgets('renders Forgot PIN link', (tester) async {
      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pump();

      expect(find.text('Forgot PIN?'), findsOneWidget);
    });

    testWidgets('does not show biometric button when biometrics disabled',
        (tester) async {
      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
          initialState: const AppLockState(
            isLoading: false,
            isLocked: true,
            hasPin: true,
            biometricEnabled: false,
            biometricAvailable: true,
          ),
        ),
      );
      await tester.pump();

      // BiometricPinButton should not be visible.
      expect(find.byType(BiometricPinButton), findsNothing);
    });
  });

  // ── Wrong PIN ──────────────────────────────────────────────────────────────

  group('wrong PIN', () {
    testWidgets('shows remaining attempts after a wrong PIN', (tester) async {
      when(() => mockPinService.verifyPin(any()))
          .thenAnswer((_) async => PinVerifyResult.incorrect(4));

      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pump();

      // Enter 6 digits.
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(d));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.textContaining('4 attempts remaining'), findsOneWidget);
    });

    testWidgets('shows lockout message after too many failures', (tester) async {
      when(() => mockPinService.verifyPin(any())).thenAnswer(
        (_) async => PinVerifyResult.lockedOut(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pump();

      for (final d in ['1', '2', '3', '4', '5', '6']) {
        await tester.tap(find.text(d));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.textContaining('Too many attempts'), findsOneWidget);
    });
  });

  // ── Forgot PIN dialog ─────────────────────────────────────────────────────

  group('forgot PIN', () {
    testWidgets('shows confirmation dialog when Forgot PIN is tapped',
        (tester) async {
      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Forgot PIN?'));
      await tester.tap(find.text('Forgot PIN?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot your PIN?'), findsOneWidget);
      expect(find.text('Wipe & Reset'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancelling forgot PIN closes the dialog', (tester) async {
      await tester.pumpWidget(
        _buildLockScreen(
          pinService: mockPinService,
          biometricService: mockBiometricService,
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Forgot PIN?'));
      await tester.tap(find.text('Forgot PIN?'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot your PIN?'), findsNothing);
    });
  });
}
