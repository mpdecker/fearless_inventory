import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firebase_auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AccountScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Cloud account management, accessed from Settings.
///
/// Signed-out state: sign-in and register entry points + explanation.
/// Signed-in state: email, verification status, sign-out, delete-account.
///
/// **App Store compliance**: Apple requires in-app account deletion
/// (App Store Review Guideline 5.1.1(v)). This screen satisfies that.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(firebaseUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12121F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Cloud Account'),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (user) => user == null
            ? _SignedOutView()
            : _SignedInView(user: user),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signed-out view
// ─────────────────────────────────────────────────────────────────────────────

class _SignedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.cloud_outlined, size: 52, color: Colors.tealAccent),
          const SizedBox(height: 20),
          const Text(
            'Optional cloud account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _PrivacyPoint(
                  icon: Icons.lock_outline,
                  text: 'Your recovery data is encrypted on this device and '
                      'never uploaded to any server.',
                ),
                const SizedBox(height: 10),
                _PrivacyPoint(
                  icon: Icons.account_circle_outlined,
                  text: 'A cloud account is purely for identity — '
                      'future features may use it for optional backup.',
                ),
                const SizedBox(height: 10),
                _PrivacyPoint(
                  icon: Icons.no_accounts_outlined,
                  text: 'You can use the app fully without creating an account.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign In',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.25)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create Account', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signed-in view
// ─────────────────────────────────────────────────────────────────────────────

class _SignedInView extends ConsumerStatefulWidget {
  final User user;
  const _SignedInView({required this.user});

  @override
  ConsumerState<_SignedInView> createState() => _SignedInViewState();
}

class _SignedInViewState extends ConsumerState<_SignedInView> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  Future<void> _resendVerification() async {
    setState(() => _isSendingVerification = true);
    try {
      await ref.read(firebaseAuthServiceProvider).resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Verification email sent. Check your inbox.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not send email. Try again later.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your recovery data stays on this device. '
          'You can sign back in at any time.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSigningOut = true);
    await ref.read(firebaseAuthServiceProvider).signOut();
    if (mounted) setState(() => _isSigningOut = false);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your cloud account. '
          'Your recovery data on this device is NOT affected — only your '
          'Firebase identity is removed.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAccount();
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await ref.read(firebaseAuthServiceProvider).deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'For security, sign out and sign back in before deleting '
                'your account.',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(FirebaseAuthService.errorMessage(e))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isVerified = user.emailVerified;
    final email = user.email ?? 'Unknown email';
    final name = user.displayName;
    final providers = user.providerData.map((p) => p.providerId).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      children: [
        // ── Avatar & name ────────────────────────────────────────────────
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: Colors.tealAccent.withOpacity(0.15),
            child: Text(
              (name?.isNotEmpty == true ? name![0] : email[0]).toUpperCase(),
              style: const TextStyle(
                color: Colors.tealAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (name != null && name.isNotEmpty)
          Center(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Center(
          child: Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Email verification status ─────────────────────────────────────
        if (!isVerified) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: Colors.orangeAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Email not verified. Check your inbox or request a new link.',
                    style: TextStyle(
                      color: Colors.orangeAccent.shade100,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: _isSendingVerification
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined, size: 18),
            label: const Text('Resend verification email'),
            onPressed:
                _isSendingVerification ? null : _resendVerification,
          ),
          const SizedBox(height: 8),
        ] else ...[
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  color: Colors.tealAccent, size: 18),
              const SizedBox(width: 6),
              Text(
                'Email verified',
                style: TextStyle(
                  color: Colors.tealAccent.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // ── Sign-in methods ───────────────────────────────────────────────
        if (providers.isNotEmpty) ...[
          const Divider(height: 32, color: Colors.white12),
          _SectionHeader('Sign-in Methods'),
          const SizedBox(height: 8),
          ...providers.map((pid) => _ProviderChip(providerId: pid)),
          const SizedBox(height: 4),
        ],

        const Divider(height: 32, color: Colors.white12),

        // ── Sign out ──────────────────────────────────────────────────────
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Colors.white70),
          title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          trailing: _isSigningOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: _isSigningOut ? null : _signOut,
        ),

        const Divider(height: 8, color: Colors.white12),

        // ── Delete account (App Store required) ───────────────────────────
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever_outlined,
              color: Colors.redAccent),
          title: const Text('Delete Account',
              style: TextStyle(color: Colors.redAccent)),
          subtitle: Text(
            'Removes your cloud identity only — local data is unaffected',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          onTap: _confirmDeleteAccount,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.1,
        ),
      );
}

class _PrivacyPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrivacyPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.tealAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderChip extends StatelessWidget {
  final String providerId;
  const _ProviderChip({required this.providerId});

  String get _label {
    switch (providerId) {
      case 'google.com':
        return 'Google';
      case 'apple.com':
        return 'Apple';
      case 'password':
        return 'Email & Password';
      default:
        return providerId;
    }
  }

  IconData get _icon {
    switch (providerId) {
      case 'google.com':
        return Icons.g_mobiledata;
      case 'apple.com':
        return Icons.apple;
      default:
        return Icons.email_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Text(_label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }
}
