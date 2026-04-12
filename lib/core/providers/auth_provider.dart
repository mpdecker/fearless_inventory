import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service provider
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton [FirebaseAuthService] — override in tests.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (_) => FirebaseAuthService(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Auth state stream
// ─────────────────────────────────────────────────────────────────────────────

/// Streams the current Firebase [User], or null when signed out.
/// Uses [FirebaseAuth.userChanges] so profile updates (e.g. email verified)
/// rebuild after [FirebaseAuthService.reloadCurrentUser].
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).userChanges;
});

// ─────────────────────────────────────────────────────────────────────────────
// Convenience providers
// ─────────────────────────────────────────────────────────────────────────────

/// True while Firebase resolves the initial auth state.
final authIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(firebaseUserProvider).isLoading;
});

/// True when the user is signed in to a Firebase account.
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(firebaseUserProvider).maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
});

/// The currently signed-in [User], or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(firebaseUserProvider).maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );
});

/// True if the signed-in user's email address has been verified.
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

/// True when the account has an email/password sign-in method.
final hasPasswordSignInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return user.providerData.any((p) => p.providerId == 'password');
});
