import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sobriety_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Holds the user's sobriety start date.
/// null  → not yet set (prompts the user to enter a date).
/// DateTime → the date they got sober (stored in secure storage).
class SobrietyDateNotifier extends StateNotifier<AsyncValue<DateTime?>> {
  SobrietyDateNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final date = await SobrietyService.getSobrietyDate();
      state = AsyncValue.data(date);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Persists [date] and updates state immediately (no flicker).
  Future<void> setDate(DateTime date) async {
    await SobrietyService.setSobrietyDate(date);
    state = AsyncValue.data(date);
  }

  /// Clears the stored date.
  Future<void> clearDate() async {
    await SobrietyService.clear();
    state = const AsyncValue.data(null);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final sobrietyDateProvider =
    StateNotifierProvider<SobrietyDateNotifier, AsyncValue<DateTime?>>(
  (ref) => SobrietyDateNotifier(),
);

/// Convenience: the current days-sober count derived from [sobrietyDateProvider].
/// Returns null when no sobriety date has been set yet.
final daysSoberProvider = Provider<int?>((ref) {
  return ref.watch(sobrietyDateProvider).maybeWhen(
        data: (date) => date != null ? SobrietyService.daysSober(date) : null,
        orElse: () => null,
      );
});
