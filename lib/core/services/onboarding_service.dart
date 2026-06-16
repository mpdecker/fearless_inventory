import 'app_secure_storage.dart';

/// Persists a simple flag in the OS secure keystore marking that the user
/// has seen and completed the first-run onboarding flow.
///
/// We reuse [FlutterSecureStorage] (already a dependency) so we avoid
/// adding a separate SharedPreferences package.
///
/// NOTE: On Android we use encrypted shared preferences; the default Keystore
/// backend silently fails on many emulators and devices that have no
/// screen-lock PIN configured, which would cause onboarding to re-run on every
/// launch. See [appSecureStorage].
class OnboardingService {
  OnboardingService._();
  static const _key = 'fearless_onboarding_complete_v1';
  static const _tabVisitedPrefix = 'fearless_tab_visited_v1_';

  // ── Onboarding ────────────────────────────────────────────────────────────

  /// Returns [true] once the user has finished onboarding at least once.
  static Future<bool> hasCompleted() async {
    final value = await appSecureStorage.read(key: _key);
    return value == 'true';
  }

  /// Call this when the user taps the final CTA on the last onboarding page.
  static Future<void> markComplete() async {
    await appSecureStorage.write(key: _key, value: 'true');
  }

  /// Resets the flag — useful during development or if the user wants to
  /// replay onboarding from Settings.
  static Future<void> reset() async {
    await appSecureStorage.delete(key: _key);
    // Also clear tab-visit flags so first-visit intros replay.
    for (int i = 1; i <= 4; i++) {
      await appSecureStorage.delete(key: '$_tabVisitedPrefix$i');
    }
  }

  // ── Tab first-visit tracking ──────────────────────────────────────────────

  /// Returns [true] if the user has ever navigated to [tabIndex] (1–4).
  static Future<bool> hasVisitedTab(int tabIndex) async {
    final value =
        await appSecureStorage.read(key: '$_tabVisitedPrefix$tabIndex');
    return value == 'true';
  }

  /// Marks [tabIndex] as visited; subsequent calls to [hasVisitedTab] will
  /// return [true].
  static Future<void> markTabVisited(int tabIndex) async {
    await appSecureStorage.write(
      key: '$_tabVisitedPrefix$tabIndex',
      value: 'true',
    );
  }
}
