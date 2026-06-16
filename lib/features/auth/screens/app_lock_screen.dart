import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_lock_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/pin_service.dart';
import '../../home/home_screen.dart';
import '../widgets/pin_pad.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppLockScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Shown on every cold start (and after background timeout) when a PIN exists.
///
/// The user can unlock with their 6-digit PIN or — if they opted in and the
/// device supports it — with Face ID / Touch ID / Fingerprint.
///
/// Security notes:
///   - After [PinService.maxFailedAttempts] consecutive wrong PINs the screen
///     shows a countdown and refuses further input until the lockout expires.
///   - Biometric auth triggers automatically on first show if enabled.
///   - "Forgot PIN?" requires wiping all app data (correct for a privacy app).
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorMessage;
  bool _isChecking = false;

  // Shake animation on wrong PIN
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  // Biometric state
  String _bioLabel = 'Biometrics';
  String _bioIconName = 'fingerprint';
  bool _bioAvailable = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _initBiometrics());
  }

  Future<void> _initBiometrics() async {
    final lockState = ref.read(appLockProvider);
    if (!lockState.biometricEnabled || !lockState.biometricAvailable) return;

    final bio = ref.read(biometricServiceProvider);
    _bioLabel = await bio.biometricLabel();
    _bioIconName = await bio.biometricIconName();
    if (mounted) {
      setState(() => _bioAvailable = true);
      _attemptBiometric();
    }
  }

  Future<void> _attemptBiometric() async {
    final bio = ref.read(biometricServiceProvider);
    final result = await bio.authenticate(
      reason: 'Unlock Fearless Inventory with $_bioLabel',
    );
    if (!mounted) return;

    if (result == BiometricResult.success) {
      _unlock();
    } else if (result == BiometricResult.lockedOut) {
      setState(() =>
          _errorMessage = '$_bioLabel is locked. Enter your PIN instead.');
    }
  }

  Future<void> _submitPin() async {
    if (_isChecking || _pin.length < PinService.pinLength) return;
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final pinService = ref.read(pinServiceProvider);
    final result = await pinService.verifyPin(_pin);

    if (!mounted) return;
    setState(() => _isChecking = false);

    switch (result) {
      case PinCorrectResult _:
        _unlock();

      case PinIncorrectResult r:
        _shakeController.forward(from: 0);
        setState(() {
          _pin = '';
          _errorMessage = r.attemptsLeft == 1
              ? '1 attempt remaining before lockout'
              : '${r.attemptsLeft} attempts remaining';
        });

      case PinLockedOutResult r:
        _shakeController.forward(from: 0);
        final mins = r.remaining.inMinutes + 1;
        setState(() {
          _pin = '';
          _errorMessage = 'Too many attempts. Try again in $mins minute'
              '${mins == 1 ? '' : 's'}.';
        });

      case PinNoPinResult _:
        // Should never happen on this screen — navigate away.
        _unlock();
    }
  }

  void _unlock() {
    ref.read(appLockProvider.notifier).unlock();
    // Replace the lock screen with HomeScreen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot your PIN?'),
        content: const Text(
          'Because your data is encrypted on this device, the only way to '
          'reset your PIN is to delete all app data.\n\n'
          'If you have a sponsor or support person you can call, we '
          'recommend doing that first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDataWipeForPinReset();
            },
            child: const Text('Wipe & Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmDataWipeForPinReset() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'This will permanently delete ALL your inventory, step work, '
          'journal entries, and amends data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No, keep my data'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _wipeAndReset();
            },
            child: const Text('Yes, delete everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _wipeAndReset() async {
    final pinService = ref.read(pinServiceProvider);
    await pinService.clearPin();
    await ref.read(appLockProvider.notifier).refresh();
    // Navigate to PIN setup (onboarding will not be shown again, but the
    // PinSetupScreen handles the empty-PIN case in the routing).
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const _DataWipedScreen()),
        (_) => false,
      );
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
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 48, 24, bottom + 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo / app name ──────────────────────────────────────
                const Icon(Icons.shield_outlined,
                    size: 48, color: Colors.tealAccent),
                const SizedBox(height: 16),
                const Text(
                  'Fearless Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your PIN to continue',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // ── PIN dots ─────────────────────────────────────────────
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

                // ── Error message ─────────────────────────────────────────
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _errorMessage != null ? 1 : 0,
                  child: Text(
                    _errorMessage ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── PIN pad ──────────────────────────────────────────────
                PinPad(
                  pinLength: PinService.pinLength,
                  currentPin: _pin,
                  onChanged: (p) => setState(() {
                    _pin = p;
                    _errorMessage = null;
                  }),
                  onSubmit: _submitPin,
                  leftAction: _bioAvailable
                      ? BiometricPinButton(
                          iconName: _bioIconName,
                          onTap: _attemptBiometric,
                        )
                      : null,
                ),
                const SizedBox(height: 32),

                // ── Forgot PIN ────────────────────────────────────────────
                TextButton(
                  onPressed: _showForgotPinDialog,
                  child: Text(
                    'Forgot PIN?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 13,
                    ),
                  ),
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
// Post-wipe informational screen
// ─────────────────────────────────────────────────────────────────────────────

class _DataWipedScreen extends ConsumerWidget {
  const _DataWipedScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 64, color: Colors.tealAccent),
              const SizedBox(height: 24),
              const Text(
                'All data has been cleared',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Restart the app to set up a new PIN and begin again.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
