import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseAuthService
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps Firebase Authentication with email/password, Google, and Apple
/// sign-in.  All data stays on-device — Firebase is used only for
/// identity management, not for storing recovery content.
///
/// Callers receive [FirebaseAuthException] on failure; use [errorMessage] to
/// convert codes into user-friendly strings before displaying them.
///
/// Inject custom instances in tests:
/// ```dart
/// FirebaseAuthService(
///   auth: mockFirebaseAuth,
///   googleSignIn: mockGoogleSignIn,
/// );
/// ```
class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ── Current state ──────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;

  /// Stream of auth-state changes.  null = signed out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isSignedIn => _auth.currentUser != null;

  // ── Email / Password ───────────────────────────────────────────────────────

  /// Register with [email] and [password].
  ///
  /// Sends a verification email immediately after account creation.
  /// Throws [FirebaseAuthException] on error.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
    }
    // Non-fatal — user can request a new one from the account screen.
    await credential.user?.sendEmailVerification().catchError((_) {});
    return credential;
  }

  /// Sign in with [email] and [password].
  /// Throws [FirebaseAuthException] on error.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  /// Send a password-reset email to [email].
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Re-send a verification email to the currently signed-in user.
  Future<void> resendVerificationEmail() =>
      _auth.currentUser?.sendEmailVerification() ?? Future.value();

  // ── Google ─────────────────────────────────────────────────────────────────

  /// Initiate Google OAuth flow and sign in to Firebase.
  ///
  /// Returns null if the user cancelled the Google sign-in sheet.
  /// Throws [FirebaseAuthException] on Firebase error.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled.

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // ── Apple ──────────────────────────────────────────────────────────────────

  /// Initiate Sign in with Apple (required by App Store when offering any
  /// other OAuth provider).
  ///
  /// Implements the nonce-based anti-replay pattern required by Apple:
  ///   1. Generate a random nonce locally.
  ///   2. Send its SHA-256 hash to Apple with the authorization request.
  ///   3. Pass the raw nonce to Firebase when creating the credential so
  ///      Firebase can verify the signature.
  ///
  /// Throws on cancellation or error.
  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final result = await _auth.signInWithCredential(oauthCredential);

    // Apple only returns the display name on the very first sign-in.
    final givenName = appleCredential.givenName;
    final familyName = appleCredential.familyName;
    if (givenName != null || familyName != null) {
      final fullName = [givenName, familyName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      await result.user?.updateDisplayName(fullName);
    }

    return result;
  }

  // ── Account management ─────────────────────────────────────────────────────

  /// Sign out from Firebase and revoke the Google token if applicable.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Permanently delete the Firebase account.
  ///
  /// **App Store requirement**: apps that create accounts must provide
  /// in-app account deletion (App Store Review Guideline 5.1.1).
  ///
  /// May throw [FirebaseAuthException] with code `requires-recent-login`.
  /// In that case, re-authenticate the user and call again.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  /// Update the display name for the signed-in user.
  Future<void> updateDisplayName(String name) =>
      _auth.currentUser?.updateDisplayName(name.trim()) ?? Future.value();

  // ── Error helpers ──────────────────────────────────────────────────────────

  /// Convert a [FirebaseAuthException.code] to a user-facing message.
  static String errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for that email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for that email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'No network connection. Please check your internet and try again.';
      case 'requires-recent-login':
        return 'For security, please sign in again before making this change.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different '
            'sign-in method. Try signing in with your original method.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }

  // ── Nonce helpers (Apple Sign-In) ──────────────────────────────────────────

  static String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)])
        .join();
  }

  static String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}
