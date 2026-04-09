import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/auth_provider.dart';
import 'package:fearless_inventory/core/services/firebase_auth_service.dart';
import 'package:fearless_inventory/features/auth/screens/login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockUserCredential extends Mock implements UserCredential {}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildLoginScreen(FirebaseAuthService authService) {
  return ProviderScope(
    overrides: [
      firebaseAuthServiceProvider.overrideWithValue(authService),
    ],
    child: const MaterialApp(home: LoginScreen()),
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
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Sign In button', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));
      expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('renders Sign in with Apple button', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));
      expect(find.text('Sign in with Apple'), findsOneWidget);
    });

    testWidgets('renders Sign in with Google button', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('renders Forgot password link', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('renders Create one link for registration', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));
      expect(find.text('Create one'), findsOneWidget);
    });
  });

  // ── Validation ─────────────────────────────────────────────────────────────

  group('form validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      // Tap Sign In without entering anything.
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email address'), 'not-an-email');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'test@example.com',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });
  });

  // ── Successful sign-in ────────────────────────────────────────────────────

  group('successful sign-in', () {
    testWidgets('calls signInWithEmail with trimmed credentials',
        (tester) async {
      when(() => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => MockUserCredential());

      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'MyPassword1',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockAuth.signInWithEmail(
            email: 'user@example.com',
            password: 'MyPassword1',
          )).called(1);
    });
  });

  // ── Error handling ─────────────────────────────────────────────────────────

  group('error handling', () {
    testWidgets('shows error banner for FirebaseAuthException', (tester) async {
      when(() => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrongpass',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Error banner should appear.
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // ── Password visibility toggle ─────────────────────────────────────────────

  group('password visibility', () {
    testWidgets('password is hidden by default', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Password'),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.obscureText, isTrue);
    });

    testWidgets('tapping eye icon toggles password visibility', (tester) async {
      await tester.pumpWidget(_buildLoginScreen(mockAuth));

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Password'),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.obscureText, isFalse);
    });
  });
}
