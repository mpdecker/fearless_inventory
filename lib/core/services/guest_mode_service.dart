import 'app_secure_storage.dart';

/// Persists whether the user chose to use the app **without** a cloud account
/// ("local-only" mode). When set, [BootstrapShell] skips the mandatory
/// Firebase sign-in gate and lets the user straight into the on-device flow.
///
/// Uses the same [appSecureStorage] backend as [OnboardingService] so we do
/// not add a separate preferences dependency.
class GuestModeService {
  GuestModeService._();
  static const _key = 'fearless_guest_mode_v1';

  /// True once the user has opted into local-only use at least once.
  static Future<bool> isEnabled() async {
    final value = await appSecureStorage.read(key: _key);
    return value == 'true';
  }

  /// Records that the user opted to continue without an account.
  static Future<void> enable() async {
    await appSecureStorage.write(key: _key, value: 'true');
  }

  /// Clears the flag (e.g. if the user later creates a real account and we
  /// want the sign-in gate back after sign-out).
  static Future<void> disable() async {
    await appSecureStorage.delete(key: _key);
  }
}
