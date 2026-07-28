import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/config/auth_provider_config.dart';

/// Google Sign-In is offered in the UI only when it can actually complete.
///
/// Shipping a visible provider that always fails is both a poor experience and
/// an App Store Guideline 2.1 risk ("app exhibits bugs"). These tests tie the
/// feature flag to the real platform configuration so the two cannot disagree.
void main() {
  final iosPlist =
      File('ios/Runner/GoogleService-Info.plist').readAsStringSync();
  final iosXcconfig =
      File('ios/Flutter/AppSecrets.xcconfig').readAsStringSync();
  final androidServices =
      File('android/app/google-services.json').readAsStringSync();

  final bool iosConfigured =
      !iosPlist.contains('REPLACE_WITH_IOS_CLIENT_ID') &&
          !iosXcconfig.contains('REPLACE_WITH_IOS_CLIENT_ID');

  // An empty oauth_client array means no SHA fingerprints are registered, so
  // Google Sign-In cannot complete on Android.
  final bool androidConfigured =
      RegExp(r'"oauth_client"\s*:\s*\[\s*\{').hasMatch(androidServices);

  test(
      'kGoogleSignInEnabled is only true when both platforms are configured',
      () {
    if (!kGoogleSignInEnabled) return; // Correctly disabled — nothing to check.

    expect(iosConfigured, isTrue,
        reason: 'iOS still has the REPLACE_WITH_IOS_CLIENT_ID placeholder — '
            'create the iOS OAuth client before enabling Google Sign-In');
    expect(androidConfigured, isTrue,
        reason: 'android/app/google-services.json has an empty oauth_client '
            'array — register the SHA-1/SHA-256 fingerprints first');
  });

  test('the flag matches the configuration currently in the repo', () {
    // Documents today's reality, and fails loudly if someone configures the
    // OAuth clients but forgets to flip the flag (or vice versa).
    final configured = iosConfigured && androidConfigured;
    expect(
      kGoogleSignInEnabled,
      configured,
      reason: configured
          ? 'OAuth clients look configured — set kGoogleSignInEnabled = true'
          : 'OAuth clients are not configured, so kGoogleSignInEnabled must '
              'stay false (iOS configured: $iosConfigured, '
              'Android configured: $androidConfigured)',
    );
  });

  test('Apple Sign In stays available whenever Google is offered', () {
    // Apple Guideline 4.8 requires Sign in with Apple alongside other
    // third-party sign-in options.
    if (kGoogleSignInEnabled) {
      expect(kAppleSignInEnabled, isTrue);
    }
  });
}
