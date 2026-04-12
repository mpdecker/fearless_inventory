import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/theme/app_colors.dart';

/// Blocks the rest of the app until the user verifies their email address.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isSending = false;
  bool _isReloading = false;
  bool _isSigningOut = false;

  Future<void> _resend() async {
    setState(() => _isSending = true);
    try {
      await ref.read(firebaseAuthServiceProvider).resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Check your inbox.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send email. Try again later.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _reloadVerification() async {
    setState(() => _isReloading = true);
    try {
      await ref.read(firebaseAuthServiceProvider).reloadCurrentUser();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FirebaseAuthService.errorMessage(e)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not refresh status.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isReloading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(firebaseAuthServiceProvider).signOut();
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(currentUserProvider)?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 56, color: Colors.orangeAccent),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a link to ${email.isEmpty ? 'your email' : email}. '
                'Open it to verify, then tap “I’ve verified” below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isReloading ? null : _reloadVerification,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isReloading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'I’ve verified',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSending ? null : _resend,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend verification email'),
              ),
              const Spacer(),
              TextButton(
                onPressed: _isSigningOut ? null : _signOut,
                child: _isSigningOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
