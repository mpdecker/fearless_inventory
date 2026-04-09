import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/auth_provider.dart';
import 'package:fearless_inventory/core/services/firebase_auth_service.dart';
import 'package:fearless_inventory/features/auth/screens/register_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildRegisterScreen(FirebaseAuthService authService) {
  return ProviderScope(
    overrides: [
      firebaseAuthServiceProvider.overrideWithValue(authService),
    ],
    child: const MaterialApp(home: RegisterScreen()),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseAuthService mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuthService();
  });

  // ── Layout ─────────────────────────────────────────────────────────────────

  group('layout', () {
    testWidgets('renders all form fields', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      expect(find.text('Display name (optional)'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
    });

    testWidgets('renders Create Account button', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));
      expect(
          find.widgetWithText(FilledButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('renders Sign in with Apple and Google buttons', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });
  });

  // ── Password validation ────────────────────────────────────────────────────

  group('password validation', () {
    testWidgets('shows error when password is too short', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('shows error when password has no uppercase letter',
        (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'alllower1',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(
        find.text('Include at least one uppercase letter'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when password has no number', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'NoNumbers!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Include at least one number'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Secure123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'Different1',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  // ── Email validation ────────────────────────────────────────────────────────

  group('email validation', () {
    testWidgets('shows error for invalid email', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'invalid',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });
  });

  // ── Successful registration ───────────────────────────────────────────────

  group('successful registration', () {
    testWidgets('calls registerWithEmail and shows verification dialog',
        (tester) async {
      final mockUser = MockUser();
      final credential = MockUserCredential();

      when(() => credential.user).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification())
          .thenAnswer((_) async {});
      when(() => mockAuth.registerWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => credential);

      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'new@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Secure123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'Secure123',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Verification dialog should appear.
      expect(find.text('Check your email'), findsOneWidget);

      verify(() => mockAuth.registerWithEmail(
            email: 'new@example.com',
            password: 'Secure123',
            displayName: any(named: 'displayName'),
          )).called(1);
    });
  });

  // ── Error handling ─────────────────────────────────────────────────────────

  group('error handling', () {
    testWidgets('shows error banner for email-already-in-use', (tester) async {
      when(() => mockAuth.registerWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(
        FirebaseAuthException(code: 'email-already-in-use'),
      );

      await tester.pumpWidget(_buildRegisterScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'taken@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Secure123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'Secure123',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
