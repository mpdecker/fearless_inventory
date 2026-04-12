import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/services/firebase_auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mocks
// ─────────────────────────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockFirebaseAuthException extends FirebaseAuthException {
  MockFirebaseAuthException({required super.code, super.message});
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback registrations (required by mocktail for non-nullable types)
// ─────────────────────────────────────────────────────────────────────────────

class FakeAuthCredential extends Fake implements AuthCredential {}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthService sut;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    sut = FirebaseAuthService(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  // ── currentUser / isSignedIn ───────────────────────────────────────────────

  group('isSignedIn', () {
    test('returns false when currentUser is null', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(sut.isSignedIn, isFalse);
    });

    test('returns true when currentUser is not null', () {
      when(() => mockAuth.currentUser).thenReturn(MockUser());
      expect(sut.isSignedIn, isTrue);
    });
  });

  // ── signInWithEmail ────────────────────────────────────────────────────────

  group('signInWithEmail', () {
    test('returns UserCredential on success', () async {
      final credential = MockUserCredential();
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      final result = await sut.signInWithEmail(
        email: 'test@example.com',
        password: 'Password1',
      );
      expect(result, equals(credential));
    });

    test('trims whitespace from email before sending', () async {
      final credential = MockUserCredential();
      when(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'Password1',
          )).thenAnswer((_) async => credential);

      await sut.signInWithEmail(
        email: '  test@example.com  ',
        password: 'Password1',
      );

      verify(() => mockAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'Password1',
          )).called(1);
    });

    test('propagates FirebaseAuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
              MockFirebaseAuthException(code: 'wrong-password'));

      expect(
        () => sut.signInWithEmail(
          email: 'test@example.com',
          password: 'badpass',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // ── registerWithEmail ──────────────────────────────────────────────────────

  group('registerWithEmail', () {
    test('creates account and sends verification email', () async {
      final mockUser = MockUser();
      final credential = MockUserCredential();

      when(() => credential.user).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification())
          .thenAnswer((_) async {});
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      final result = await sut.registerWithEmail(
        email: 'new@example.com',
        password: 'Secure123',
      );

      expect(result, equals(credential));
      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('sets displayName when provided', () async {
      final mockUser = MockUser();
      final credential = MockUserCredential();

      when(() => credential.user).thenReturn(mockUser);
      when(() => mockUser.sendEmailVerification())
          .thenAnswer((_) async {});
      when(() => mockUser.updateDisplayName(any()))
          .thenAnswer((_) async {});
      when(() => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => credential);

      await sut.registerWithEmail(
        email: 'new@example.com',
        password: 'Secure123',
        displayName: 'Alice',
      );

      verify(() => mockUser.updateDisplayName('Alice')).called(1);
    });
  });

  // ── sendPasswordReset ──────────────────────────────────────────────────────

  group('sendPasswordReset', () {
    test('calls sendPasswordResetEmail with trimmed email', () async {
      when(() => mockAuth.sendPasswordResetEmail(
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await sut.sendPasswordReset('  reset@example.com  ');

      verify(() =>
              mockAuth.sendPasswordResetEmail(email: 'reset@example.com'))
          .called(1);
    });
  });

  // ── signOut ────────────────────────────────────────────────────────────────

  group('signOut', () {
    test('signs out from both Firebase and Google', () async {
      when(() => mockGoogleSignIn.signOut())
          .thenAnswer((_) async => null);
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await sut.signOut();

      verify(() => mockGoogleSignIn.signOut()).called(1);
      verify(() => mockAuth.signOut()).called(1);
    });
  });

  // ── signInWithGoogle ───────────────────────────────────────────────────────

  group('signInWithGoogle', () {
    test('returns null when user cancels Google sign-in', () async {
      when(() => mockGoogleSignIn.signIn())
          .thenAnswer((_) async => null);

      final result = await sut.signInWithGoogle();
      expect(result, isNull);
    });
  });

  // ── errorMessage ──────────────────────────────────────────────────────────

  group('errorMessage', () {
    final testCases = {
      'user-not-found': 'No account found',
      'wrong-password': 'Incorrect email or password',
      'invalid-credential': 'Incorrect email or password',
      'email-already-in-use': 'An account already exists',
      'invalid-email': 'valid email address',
      'weak-password': 'at least 8 characters',
      'user-disabled': 'disabled',
      'too-many-requests': 'Too many failed attempts',
      'network-request-failed': 'No network connection',
      'requires-recent-login': 'sign in again',
    };

    for (final entry in testCases.entries) {
      test('maps "${entry.key}" to a message containing "${entry.value}"',
          () {
        final e = MockFirebaseAuthException(code: entry.key);
        final msg = FirebaseAuthService.errorMessage(e);
        expect(
          msg.toLowerCase(),
          contains(entry.value.toLowerCase()),
          reason: 'Expected "$msg" to mention "${entry.value}"',
        );
      });
    }

    test('returns a fallback for unknown error codes', () {
      final e =
          MockFirebaseAuthException(code: 'an-unknown-code', message: null);
      final msg = FirebaseAuthService.errorMessage(e);
      expect(msg, isNotEmpty);
    });

    test('returns e.message for unknown codes when message is set', () {
      final e = MockFirebaseAuthException(
        code: 'an-unknown-code',
        message: 'Custom backend message',
      );
      final msg = FirebaseAuthService.errorMessage(e);
      expect(msg, contains('Custom backend message'));
    });
  });

  // ── reloadCurrentUser ─────────────────────────────────────────────────────

  group('reloadCurrentUser', () {
    test('calls reload on current user', () async {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async {});

      await sut.reloadCurrentUser();

      verify(() => mockUser.reload()).called(1);
    });

    test('completes when no user is signed in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      await expectLater(sut.reloadCurrentUser(), completes);
    });
  });

  // ── updatePassword ─────────────────────────────────────────────────────────

  group('updatePassword', () {
    test('reauthenticates then updates password', () async {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());
      when(() => mockUser.updatePassword(any())).thenAnswer((_) async {});

      await sut.updatePassword(
        email: 'user@example.com',
        currentPassword: 'OldPassword1',
        newPassword: 'NewPassword1',
      );

      verify(() => mockUser.updatePassword('NewPassword1')).called(1);
    });
  });

  // ── reauthenticateWithPassword ─────────────────────────────────────────────

  group('reauthenticateWithPassword', () {
    test('throws when no user is signed in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => sut.reauthenticateWithPassword(
          email: 'a@b.com',
          password: 'x',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('calls reauthenticateWithCredential', () async {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());

      await sut.reauthenticateWithPassword(
        email: 'user@example.com',
        password: 'Secret1',
      );

      verify(() => mockUser.reauthenticateWithCredential(any())).called(1);
    });
  });

  // ── deleteAccount ────────────────────────────────────────────────────────

  group('deleteAccount', () {
    test('calls delete on the current user', () async {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.delete()).thenAnswer((_) async {});

      await sut.deleteAccount();

      verify(() => mockUser.delete()).called(1);
    });

    test('does nothing when no user is signed in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      // Should complete without throwing.
      await expectLater(sut.deleteAccount(), completes);
    });
  });
}
