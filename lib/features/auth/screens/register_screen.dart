import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../widgets/social_auth_buttons.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RegisterScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Firebase account registration: display name (optional), email, password.
/// Also offers Sign in with Apple and Sign in with Google.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Loading guard ──────────────────────────────────────────────────────────

  Future<void> _withLoading(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = FirebaseAuthService.errorMessage(e));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Auth actions ───────────────────────────────────────────────────────────

  void _popIfStacked() {
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) nav.pop();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _withLoading(() async {
      await ref.read(firebaseAuthServiceProvider).registerWithEmail(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            displayName: _nameCtrl.text.isEmpty ? null : _nameCtrl.text,
          );
      if (mounted) {
        _showVerificationDialog();
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    await _withLoading(() async {
      final result =
          await ref.read(firebaseAuthServiceProvider).signInWithGoogle();
      if (result == null) return;
      if (mounted) _popIfStacked();
    });
  }

  Future<void> _signInWithApple() async {
    await _withLoading(() async {
      await ref.read(firebaseAuthServiceProvider).signInWithApple();
      if (mounted) _popIfStacked();
    });
  }

  // ── Post-register dialog ───────────────────────────────────────────────────

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Check your email'),
        content: Text(
          'We sent a verification link to ${_emailCtrl.text}. '
          'Open it to verify your email — you will need to confirm before '
          'continuing past the next screen.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _popIfStacked();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Include at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ────────────────────────────────────────────────
                const Icon(Icons.person_add_outlined,
                    size: 52, color: Colors.tealAccent),
                const SizedBox(height: 16),
                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your recovery data stays encrypted on this device',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Error banner ──────────────────────────────────────────
                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],

                // ── Display name (optional) ───────────────────────────────
                _AuthTextField(
                  controller: _nameCtrl,
                  label: 'Display name (optional)',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: 14),

                // ── Email ─────────────────────────────────────────────────
                _AuthTextField(
                  controller: _emailCtrl,
                  label: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 14),

                // ── Password ──────────────────────────────────────────────
                _AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '8+ characters · at least one uppercase letter and number',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Confirm password ──────────────────────────────────────
                _AuthTextField(
                  controller: _confirmPasswordCtrl,
                  label: 'Confirm password',
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirmPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _register(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Register button ───────────────────────────────────────
                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 28),

                // ── Social options ────────────────────────────────────────
                const OrDivider(),
                const SizedBox(height: 20),

                SignInWithAppleButton(
                  onPressed: _isLoading ? null : _signInWithApple,
                ),
                const SizedBox(height: 12),

                SignInWithGoogleButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 36),

                // ── Login link ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _goToLogin,
                      child: const Text(
                        'Sign in',
                        style:
                            TextStyle(color: Colors.tealAccent, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets (imported from login_screen.dart via barrel or re-declared)
// ─────────────────────────────────────────────────────────────────────────────

// Reuse _AuthTextField and _ErrorBanner from login_screen.dart by re-exporting,
// or define them here. To keep files self-contained we re-export via import and
// rely on Dart's tree-shaking. The classes are private (_) so they must be
// duplicated or placed in a shared widget file.
// For clarity, we redeclare them here.

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final List<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;

  const _AuthTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.tealAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
