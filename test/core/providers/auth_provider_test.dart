import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fearless_inventory/core/providers/auth_provider.dart';
import 'package:fearless_inventory/core/services/firebase_auth_service.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

class MockUser extends Mock implements User {}

void main() {
  late StreamController<User?> authController;
  late MockFirebaseAuthService mockAuth;
  late ProviderContainer container;

  setUp(() {
    authController = StreamController<User?>.broadcast();
    mockAuth = MockFirebaseAuthService();
    when(() => mockAuth.authStateChanges)
        .thenAnswer((_) => authController.stream);

    container = ProviderContainer(
      overrides: [
        firebaseAuthServiceProvider.overrideWithValue(mockAuth),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await authController.close();
  });

  group('derived auth providers', () {
    test('isSignedInProvider is false when user is null', () async {
      final first = container.read(firebaseUserProvider.future);
      authController.add(null);
      await first;

      expect(container.read(isSignedInProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(isEmailVerifiedProvider), isFalse);
    });

    test('isSignedInProvider is true when user is non-null', () async {
      final user = MockUser();
      when(() => user.emailVerified).thenReturn(true);
      final first = container.read(firebaseUserProvider.future);
      authController.add(user);
      await first;

      expect(container.read(isSignedInProvider), isTrue);
      expect(container.read(currentUserProvider), same(user));
      expect(container.read(isEmailVerifiedProvider), isTrue);
    });

    test('isEmailVerifiedProvider is false when user not verified', () async {
      final user = MockUser();
      when(() => user.emailVerified).thenReturn(false);
      final first = container.read(firebaseUserProvider.future);
      authController.add(user);
      await first;

      expect(container.read(isSignedInProvider), isTrue);
      expect(container.read(isEmailVerifiedProvider), isFalse);
    });
  });
}
