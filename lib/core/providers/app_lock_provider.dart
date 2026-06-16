import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/biometric_service.dart';
import '../services/pin_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service providers
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton [PinService] — override in tests to inject a fake storage.
final pinServiceProvider = Provider<PinService>(
  (_) => const PinService(),
);

/// Singleton [BiometricService] — override in tests to inject a mock auth.
final biometricServiceProvider = Provider<BiometricService>(
  (_) => BiometricService(),
);

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class AppLockState {
  /// True while the initial PIN / biometric state is being loaded from
  /// secure storage on first build.
  final bool isLoading;

  /// Whether the app is currently locked (showing the lock screen).
  final bool isLocked;

  /// Whether a PIN has been configured on this device.
  final bool hasPin;

  /// Whether the user opted in to biometric unlock.
  final bool biometricEnabled;

  /// Whether the device supports biometric or device-credential auth.
  final bool biometricAvailable;

  const AppLockState({
    this.isLoading = true,
    this.isLocked = true,
    this.hasPin = false,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
  });

  AppLockState copyWith({
    bool? isLoading,
    bool? isLocked,
    bool? hasPin,
    bool? biometricEnabled,
    bool? biometricAvailable,
  }) =>
      AppLockState(
        isLoading: isLoading ?? this.isLoading,
        isLocked: isLocked ?? this.isLocked,
        hasPin: hasPin ?? this.hasPin,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      );

  @override
  String toString() => 'AppLockState('
      'isLoading: $isLoading, '
      'isLocked: $isLocked, '
      'hasPin: $hasPin, '
      'biometricEnabled: $biometricEnabled, '
      'biometricAvailable: $biometricAvailable)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AppLockNotifier extends Notifier<AppLockState> {
  @override
  AppLockState build() {
    // Kick off async load; state starts as loading.
    Future.microtask(_initialize);
    return const AppLockState();
  }

  Future<void> _initialize() async {
    final pin = ref.read(pinServiceProvider);
    final bio = ref.read(biometricServiceProvider);

    final hasPin = await pin.hasPin();
    final biometricEnabled = await pin.isBiometricEnabled();
    final biometricAvailable = await bio.isAvailable();

    state = AppLockState(
      isLoading: false,
      isLocked: hasPin, // locked on every cold start when a PIN exists
      hasPin: hasPin,
      biometricEnabled: biometricEnabled,
      biometricAvailable: biometricAvailable,
    );
  }

  // ── Mutations called by screens ────────────────────────────────────────────

  /// Unlock the app after successful PIN or biometric verification.
  void unlock() => state = state.copyWith(isLocked: false, isLoading: false);

  /// Lock the app (called when the app is backgrounded long enough).
  void lock() {
    if (state.hasPin) state = state.copyWith(isLocked: true);
  }

  /// Reload PIN / biometric state from secure storage.
  /// Call after [PinService.setPin] or toggling biometrics.
  Future<void> refresh() => _initialize();
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final appLockProvider =
    NotifierProvider<AppLockNotifier, AppLockState>(AppLockNotifier.new);
