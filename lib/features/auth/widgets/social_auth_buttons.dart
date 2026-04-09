import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Divider with label
// ─────────────────────────────────────────────────────────────────────────────

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign in with Apple button
// ─────────────────────────────────────────────────────────────────────────────

/// Apple-HIG–compliant button. Per App Store guidelines this must be rendered
/// with the official Apple style when listed alongside other social providers.
class SignInWithAppleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SignInWithAppleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SocialButton(
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      icon: const _AppleIcon(),
      label: 'Sign in with Apple',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign in with Google button
// ─────────────────────────────────────────────────────────────────────────────

class SignInWithGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SignInWithGoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SocialButton(
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      icon: const _GoogleIcon(),
      label: 'Sign in with Google',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared button shell
// ─────────────────────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: Colors.white.withOpacity(0.15)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: icon),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SVG-free icons (custom painted to avoid extra dependencies)
// ─────────────────────────────────────────────────────────────────────────────

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Colors.black, size: 20);
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    // Simple "G" lettermark as a stand-in; replace with the official SVG asset
    // if you add the google_sign_in_web asset bundle.
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
