import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_lock_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/guest_mode_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/app_colors.dart';
import '../../features/auth/screens/app_lock_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/auth/screens/welcome_auth_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';

/// Single coordinator for onboarding → auth → email verify → PIN → lock → home.
///
/// Avoids [Navigator.pushReplacement] between these phases so the flow stays a
/// single rebuild-driven decision. A signed-in (verified) user and a user who
/// chose local-only ("guest") mode both proceed to the on-device flow; only a
/// signed-out, non-guest user sees the sign-in gate.
class BootstrapShell extends ConsumerWidget {
  const BootstrapShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(onboardingCompleteProvider);

    return onboardingAsync.when(
      loading: () => const _BootstrapScaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.cyanSecondary),
        ),
      ),
      error: (e, _) => _BootstrapScaffold(
        body: _RetryBody(
          message: e.toString(),
          onRetry: () => ref.invalidate(onboardingCompleteProvider),
        ),
      ),
      data: (onboardingDone) {
        if (!onboardingDone) {
          return const OnboardingScreen();
        }

        final userAsync = ref.watch(firebaseUserProvider);

        return userAsync.when(
          loading: () => const _BootstrapScaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.cyanSecondary),
            ),
          ),
          error: (e, _) => _BootstrapScaffold(
            body: _RetryBody(
              message: e.toString(),
              onRetry: () => ref.invalidate(firebaseUserProvider),
            ),
          ),
          data: (user) {
            final isGuest = ref.watch(guestModeProvider);

            // Signed-out and not in local-only mode → sign-in gate.
            if (user == null && !isGuest) {
              return const WelcomeAuthScreen();
            }
            // A real (non-guest) account must verify its email first.
            if (user != null && !user.emailVerified) {
              return const EmailVerificationScreen();
            }

            final lockState = ref.watch(appLockProvider);

            if (lockState.isLoading) {
              return const _BootstrapScaffold(
                body: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.cyanSecondary),
                ),
              );
            }

            if (!lockState.hasPin) {
              return const PinSetupScreen();
            }
            if (lockState.isLocked) {
              return const AppLockScreen();
            }
            return const HomeScreen();
          },
        );
      },
    );
  }
}

class _BootstrapScaffold extends StatelessWidget {
  final Widget body;
  const _BootstrapScaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: body,
    );
  }
}

class _RetryBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RetryBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
