import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';
import '../services/sponsor_call_prefs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SponsorCallConfigNotifier
    extends StateNotifier<AsyncValue<SponsorCallConfig>> {
  SponsorCallConfigNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  final _prefs = const SponsorCallPrefs();

  Future<void> _load() async {
    try {
      final config = await _prefs.load();
      state = AsyncValue.data(config);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Persist [config], (re)schedule or cancel the notification, and update
  /// state immediately so the UI reflects the change without a reload.
  Future<void> save(SponsorCallConfig config) async {
    await _prefs.save(config);

    final svc = NotificationService();
    if (config.enabled) {
      await svc.scheduleSponsorCallReminder(
        hour: config.hour,
        minute: config.minute,
        frequency: config.frequency,
        weekday: config.weekday,
      );
    } else {
      await svc.cancelSponsorCallReminder();
    }

    state = AsyncValue.data(config);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final sponsorCallConfigProvider = StateNotifierProvider<
    SponsorCallConfigNotifier, AsyncValue<SponsorCallConfig>>(
  (_) => SponsorCallConfigNotifier(),
);
