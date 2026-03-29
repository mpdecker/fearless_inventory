import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists a simple flag in the OS secure keystore marking that the user
/// has seen and completed the first-run onboarding flow.
///
/// We reuse [FlutterSecureStorage] (already a dependency) so we avoid
/// adding a separate SharedPreferences package.
///
/// NOTE: We must use [AndroidOptions] with [encryptedSharedPreferences] set
/// to true; the default Keystore backend silently fails on many Android
/// emulators and devices that have no screen-lock PIN configured, which
/// would cause onboarding to re-run on every launch.
class OnboardingService {
  OnboardingService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _key = 'fearless_onboarding_complete_v1';
  static const _tabVisitedPrefix = 'fearless_tab_visited_v1_';

  // ── Onboarding ────────────────────────────────────────────────────────────

  /// Returns [true] once the user has finished onboarding at least once.
  static Future<bool> hasCompleted() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  /// Call this when the user taps the final CTA on the last onboarding page.
  static Future<void> markComplete() async {
    await _storage.write(key: _key, value: 'true');
  }

  /// Resets the flag — useful during development or if the user wants to
  /// replay onboarding from Settings.
  static Future<void> reset() async {
    await _storage.delete(key: _key);
    // Also clear tab-visit flags so first-visit intros replay.
    for (int i = 1; i <= 4; i++) {
      await _storage.delete(key: '$_tabVisitedPrefix$i');
    }
  }

  // ── Tab first-visit tracking ──────────────────────────────────────────────

  /// Returns [true] if the user has ever navigated to [tabIndex] (1–4).
  static Future<bool> hasVisitedTab(int tabIndex) async {
    final value = await _storage.read(key: '$_tabVisitedPrefix$tabIndex');
    return value == 'true';
  }

  /// Marks [tabIndex] as visited; subsequent calls to [hasVisitedTab] will
  /// return [true].
  static Future<void> markTabVisited(int tabIndex) async {
    await _storage.write(key: '$_tabVisitedPrefix$tabIndex', value: 'true');
  }
}
