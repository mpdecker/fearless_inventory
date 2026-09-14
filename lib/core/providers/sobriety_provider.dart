import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/sobriety_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Holds the user's sobriety start date.
/// null  → not yet set (prompts the user to enter a date).
/// DateTime → the date they got sober (stored in the cloud-synced database).
class SobrietyDateNotifier extends StateNotifier<AsyncValue<DateTime?>> {
  late final AppDatabase _db;

  SobrietyDateNotifier(AppDatabase db) : super(const AsyncValue.loading()) {
    _db = db;
    _load();
  }

  /// Constructs a notifier pre-seeded with [initialValue] and skips the
  /// database read. Use only in tests.
  @visibleForTesting
  SobrietyDateNotifier.testing({DateTime? initialValue})
      : super(AsyncValue.data(initialValue));

  Future<void> _load() async {
    try {
      final date = await SobrietyService.getSobrietyDate(_db);
      state = AsyncValue.data(date);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Persists [date] and updates state immediately (no flicker).
  Future<void> setDate(DateTime date) async {
    await SobrietyService.setSobrietyDate(_db, date);
    state = AsyncValue.data(date);
  }

  /// Clears the stored date.
  Future<void> clearDate() async {
    await SobrietyService.clear(_db);
    state = const AsyncValue.data(null);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final sobrietyDateProvider =
    StateNotifierProvider<SobrietyDateNotifier, AsyncValue<DateTime?>>(
  (ref) => SobrietyDateNotifier(ref.watch(databaseProvider)),
);

/// Convenience: the current days-sober count derived from [sobrietyDateProvider].
/// Returns null when no sobriety date has been set yet.
final daysSoberProvider = Provider<int?>((ref) {
  return ref.watch(sobrietyDateProvider).maybeWhen(
        data: (date) => date != null ? SobrietyService.daysSober(date) : null,
        orElse: () => null,
      );
});
