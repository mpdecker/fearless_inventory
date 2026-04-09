import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firebase_auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ForgotPasswordScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Sends a Firebase password-reset email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _sendReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(firebaseAuthServiceProvider)
          .sendPasswordReset(_emailCtrl.text);
      if (mounted) setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = FirebaseAuthService.errorMessage(e));
      }
    } catch (_) {
      if (mounted) {
        setState(
            () => _errorMessage = 'An unexpected error occurred. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: _emailSent ? _SuccessView(email: _emailCtrl.text) : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onSend: _sendReset,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-views
// ─────────────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSend;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.errorMessage,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset_outlined,
              size: 52, color: Colors.tealAccent),
          const SizedBox(height: 20),
          const Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Enter your account email and we'll send a reset link.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          if (errorMessage != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSend(),
            autofillHints: const [AutofillHints.email],
            style: const TextStyle(color: Colors.white),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email address',
              labelStyle:
                  TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Colors.tealAccent, width: 1.5),
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: isLoading ? null : onSend,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black),
                  )
                : const Text(
                    'Send Reset Link',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            size: 64, color: Colors.tealAccent),
        const SizedBox(height: 24),
        const Text(
          'Reset link sent',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Check your inbox at $email and follow the link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Sign In'),
        ),
      ],
    );
  }
}
