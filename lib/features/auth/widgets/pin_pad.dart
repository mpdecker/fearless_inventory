import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PinDots
// ─────────────────────────────────────────────────────────────────────────────

/// A row of [count] circles that fill as digits are entered.
class PinDots extends StatelessWidget {
  final int count;
  final int filled;
  final Color activeColor;
  final bool hasError;

  const PinDots({
    super.key,
    required this.count,
    required this.filled,
    this.activeColor = Colors.tealAccent,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = hasError ? Colors.redAccent : activeColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? dotColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? dotColor : Colors.white38,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PinPad
// ─────────────────────────────────────────────────────────────────────────────

/// Numeric PIN-entry pad.
///
/// Calls [onChanged] for every digit append/delete and [onSubmit] when
/// [pinLength] digits have been accumulated (auto-submit) or when the user
/// taps the confirm key (if [showConfirm] is true).
///
/// The left action key is occupied by [leftAction] (e.g. a biometric button).
/// Pass null to leave it blank.
class PinPad extends StatelessWidget {
  final int pinLength;
  final String currentPin;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmit;
  final Widget? leftAction;

  const PinPad({
    super.key,
    this.pinLength = 6,
    required this.currentPin,
    required this.onChanged,
    this.onSubmit,
    this.leftAction,
  });

  void _handleDigit(String digit) {
    if (currentPin.length >= pinLength) return;
    final next = currentPin + digit;
    onChanged(next);
    HapticFeedback.lightImpact();
    if (next.length == pinLength) {
      onSubmit?.call();
    }
  }

  void _handleDelete() {
    if (currentPin.isEmpty) return;
    onChanged(currentPin.substring(0, currentPin.length - 1));
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits
          .map((d) => _DigitButton(label: d, onTap: () => _handleDigit(d)))
          .toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left slot: biometric button or empty space.
        SizedBox(
          width: 80,
          height: 80,
          child: leftAction != null
              ? Center(child: leftAction)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 12),
        _DigitButton(label: '0', onTap: () => _handleDigit('0')),
        const SizedBox(width: 12),
        // Delete key.
        _ActionButton(
          icon: Icons.backspace_outlined,
          semanticsLabel: 'Delete digit',
          onTap: _handleDelete,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private button widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DigitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DigitButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Material(
          color: Colors.white.withOpacity(0.07),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            splashColor: AppColors.brightCyan.withOpacity(0.2),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Semantics(
          label: semanticsLabel,
          button: true,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(icon, color: Colors.white70, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BiometricPinButton — used as the left-action slot in AppLockScreen
// ─────────────────────────────────────────────────────────────────────────────

class BiometricPinButton extends StatelessWidget {
  final String iconName; // "face" or "fingerprint"
  final VoidCallback onTap;

  const BiometricPinButton({
    super.key,
    required this.iconName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon =
        iconName == 'face' ? Icons.face_outlined : Icons.fingerprint_outlined;
    return Semantics(
      label: 'Use biometric unlock',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: Colors.tealAccent, size: 36),
      ),
    );
  }
}
