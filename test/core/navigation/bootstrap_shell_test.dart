import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/navigation/bootstrap_shell.dart';
import 'package:fearless_inventory/core/providers/app_lock_provider.dart';
import 'package:fearless_inventory/core/providers/auth_provider.dart';
import 'package:fearless_inventory/core/providers/guest_mode_provider.dart';
import 'package:fearless_inventory/core/providers/onboarding_provider.dart';
import 'package:fearless_inventory/features/auth/screens/welcome_auth_screen.dart';

/// Lock notifier that returns a fixed state (loading), so the post-gate flow
/// stops at the bootstrap spinner instead of building downstream screens.
class _FixedLoadingLockNotifier extends AppLockNotifier {
  @override
  AppLockState build() => const AppLockState(isLoading: true);
}

class _FixedGuestNotifier extends GuestModeNotifier {
  final bool _value;
  _FixedGuestNotifier(this._value);
  @override
  bool build() => _value;
}

Widget _harness({required bool guest}) {
  return ProviderScope(
    overrides: [
      onboardingCompleteProvider.overrideWith((ref) async => true),
      // Signed out.
      firebaseUserProvider.overrideWith((ref) => Stream<User?>.value(null)),
      guestModeProvider.overrideWith(() => _FixedGuestNotifier(guest)),
      appLockProvider.overrideWith(() => _FixedLoadingLockNotifier()),
    ],
    child: const MaterialApp(home: BootstrapShell()),
  );
}

void main() {
  // Resolve the nested onboarding Future then the auth Stream. Not
  // pumpAndSettle: the bootstrap/lock CircularProgressIndicator animates
  // forever and would time it out.
  Future<void> settleGate(WidgetTester tester) async {
    await tester.pump(); // onboarding future
    await tester.pump(const Duration(milliseconds: 20)); // auth stream
    await tester.pump(const Duration(milliseconds: 20)); // rebuild
  }

  testWidgets('signed-out non-guest user sees the sign-in gate',
      (tester) async {
    await tester.pumpWidget(_harness(guest: false));
    await settleGate(tester);

    expect(find.byType(WelcomeAuthScreen), findsOneWidget);
  });

  testWidgets('signed-out guest user skips the sign-in gate', (tester) async {
    await tester.pumpWidget(_harness(guest: true));
    await settleGate(tester);

    // Guest bypasses the gate; lock state is "loading" so we land on the
    // bootstrap spinner rather than the WelcomeAuthScreen.
    expect(find.byType(WelcomeAuthScreen), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping "Continue without an account" dismisses the gate',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    // Real guestModeProvider (starts false), so the button's enterGuestMode()
    // actually persists and flips state.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWith((ref) async => true),
          firebaseUserProvider.overrideWith((ref) => Stream<User?>.value(null)),
          appLockProvider.overrideWith(() => _FixedLoadingLockNotifier()),
        ],
        child: const MaterialApp(home: BootstrapShell()),
      ),
    );
    await settleGate(tester);
    expect(find.byType(WelcomeAuthScreen), findsOneWidget);

    await tester.tap(find.text('Continue without an account'));
    await settleGate(tester);

    expect(find.byType(WelcomeAuthScreen), findsNothing);
  });
}
