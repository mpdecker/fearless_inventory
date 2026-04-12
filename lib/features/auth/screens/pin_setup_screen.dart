import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_lock_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/pin_service.dart';
import '../widgets/pin_pad.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PinSetupScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Two-step PIN creation: enter then confirm.
///
/// After saving the PIN the user is offered biometric unlock (if available),
/// then the app shell continues to the lock screen or home.
///
/// Pass [isChangingPin] = true when the user updates their PIN from Settings.
class PinSetupScreen extends ConsumerStatefulWidget {
  final bool isChangingPin;

  const PinSetupScreen({super.key, this.isChangingPin = false});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────

enum _SetupStep { enter, confirm }

class _PinSetupScreenState extends ConsumerState<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  _SetupStep _step = _SetupStep.enter;
  String _firstPin = '';
  String _pin = '';
  String? _errorMessage;

  // Shake on mismatch
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // Biometric
  bool _bioAvailable = false;
  String _bioLabel = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics());
  }

  Future<void> _checkBiometrics() async {
    final bio = ref.read(biometricServiceProvider);
    final available = await bio.isAvailable();
    if (!available) return;
    final label = await bio.biometricLabel();
    if (mounted) setState(() {
      _bioAvailable = true;
      _bioLabel = label;
    });
  }

  void _onPinChanged(String p) => setState(() {
        _pin = p;
        _errorMessage = null;
      });

  void _onSubmit() {
    if (_pin.length < PinService.pinLength) return;

    if (_step == _SetupStep.enter) {
      // Move to confirmation step.
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _step = _SetupStep.confirm;
      });
    } else {
      _confirmPin();
    }
  }

  Future<void> _confirmPin() async {
    if (_pin != _firstPin) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() {
        _pin = '';
        _errorMessage = "PINs don't match. Please try again.";
        _step = _SetupStep.enter;
        _firstPin = '';
      });
      return;
    }

    final pinService = ref.read(pinServiceProvider);
    await pinService.setPin(_pin);

    if (!mounted) return;

    if (_bioAvailable) {
      _showBiometricPrompt();
    } else {
      _finish(biometricEnabled: false);
    }
  }

  void _showBiometricPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Use $_bioLabel?'),
        content: Text(
          'You can unlock the app with $_bioLabel instead of your PIN. '
          'You can change this in Settings at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finish(biometricEnabled: false);
            },
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finish(biometricEnabled: true);
            },
            child: Text('Enable $_bioLabel'),
          ),
        ],
      ),
    );
  }

  Future<void> _finish({required bool biometricEnabled}) async {
    final pinService = ref.read(pinServiceProvider);
    await pinService.setBiometricEnabled(enabled: biometricEnabled);
    await ref.read(appLockProvider.notifier).refresh();

    if (!mounted) return;

    if (widget.isChangingPin) {
      Navigator.of(context).pop(); // Return to Settings.
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isConfirm = _step == _SetupStep.confirm;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: widget.isChangingPin
          ? AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Change PIN'),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 48, 24, bottom + 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Header ───────────────────────────────────────────────
                const Icon(Icons.lock_outline,
                    size: 48, color: Colors.tealAccent),
                const SizedBox(height: 16),
                Text(
                  isConfirm ? 'Confirm your PIN' : 'Create a PIN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isConfirm
                      ? 'Enter the same PIN again to confirm'
                      : 'Choose a ${PinService.pinLength}-digit PIN to protect your recovery data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // ── Progress indicator ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepDot(active: true, label: '1'),
                    const _StepLine(),
                    _StepDot(active: isConfirm, label: '2'),
                  ],
                ),
                const SizedBox(height: 36),

                // ── PIN dots (with shake animation) ───────────────────────
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (_, child) {
                    final offset =
                        ((_shakeAnimation.value * 3).round().isOdd ? 1 : -1) *
                            8.0 *
                            (1 - _shakeAnimation.value);
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: PinDots(
                    count: PinService.pinLength,
                    filled: _pin.length,
                    hasError: _errorMessage != null,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Error ─────────────────────────────────────────────────
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _errorMessage != null ? 1 : 0,
                  child: Text(
                    _errorMessage ?? '',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── PIN pad ───────────────────────────────────────────────
                PinPad(
                  pinLength: PinService.pinLength,
                  currentPin: _pin,
                  onChanged: _onPinChanged,
                  onSubmit: _onSubmit,
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
// Step indicator widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.tealAccent : Colors.white12,
        border: Border.all(
          color: active ? Colors.tealAccent : Colors.white24,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 1.5,
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
