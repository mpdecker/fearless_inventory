/// Which third-party sign-in options the app is actually configured to offer.
///
/// Sign-in buttons are gated on these so the app never shows a provider that
/// cannot complete — a visible-but-broken login is both bad for the user and an
/// App Store Guideline 2.1 rejection risk.
library;

/// Whether Google Sign-In is fully configured on **both** platforms.
///
/// Currently `false` because the OAuth clients have not been created:
///
/// * iOS — `ios/Runner/GoogleService-Info.plist` and
///   `ios/Flutter/AppSecrets.xcconfig` still contain the literal
///   `REPLACE_WITH_IOS_CLIENT_ID` placeholder.
/// * Android — the `oauth_client` array in `android/app/google-services.json`
///   is empty, because no debug/release SHA-1 and SHA-256 fingerprints have
///   been registered with the Firebase project.
///
/// To enable:
/// 1. In the Firebase console, create the iOS OAuth client and add the Android
///    SHA-1/SHA-256 fingerprints for both the debug and upload keystores.
/// 2. Re-download `GoogleService-Info.plist` and `google-services.json`, and
///    set `GOOGLE_REVERSED_CLIENT_ID` in `AppSecrets.xcconfig` to match
///    `REVERSED_CLIENT_ID` in the new plist.
/// 3. Flip this to `true` and verify sign-in on a physical device per platform.
///
/// A test asserts the placeholders are gone before this may be `true`, so the
/// flag cannot be enabled against an unconfigured project.
const bool kGoogleSignInEnabled = false;

/// Whether Sign in with Apple is offered.
///
/// The `com.apple.developer.applesignin` entitlement is present, so this stays
/// on. Apple also *requires* it whenever another third-party sign-in option is
/// offered (Guideline 4.8), so it must not be disabled while
/// [kGoogleSignInEnabled] is true.
const bool kAppleSignInEnabled = true;
