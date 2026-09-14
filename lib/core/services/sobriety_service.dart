import 'package:drift/drift.dart' show Value;

import '../database/database.dart';
import 'app_secure_storage.dart';

/// Persists the user's sobriety date in the cloud-synced Drift database (a
/// singleton `UserSettings` row) — unlike device-local settings, which stay
/// in `appSecureStorage`, the sobriety date needs to survive a cloud
/// backup/restore onto a different device.
///
/// Pre-schema-v17 installs stored it in `appSecureStorage` under
/// [_legacyDeviceKey] (or, before that, [_legacyStorageKey]); the first read
/// on such an install migrates the value into the database and deletes both
/// legacy keys.
class SobrietyService {
  static const _legacyDeviceKey = 'fearless_sobriety_date';
  static const _legacyStorageKey = 'sobriety_date_v1';
  static const _settingsRowId = 0;

  /// Returns the stored sobriety date, or null if not yet set.
  static Future<DateTime?> getSobrietyDate(AppDatabase db) async {
    final row = await (db.select(db.userSettings)
          ..where((t) => t.id.equals(_settingsRowId)))
        .getSingleOrNull();
    if (row?.sobrietyDate != null) return row!.sobrietyDate;

    var legacy = await appSecureStorage.read(key: _legacyDeviceKey);
    legacy ??= await appSecureStorage.read(key: _legacyStorageKey);
    if (legacy == null) return null;
    final parsed = DateTime.tryParse(legacy);
    if (parsed == null) return null;

    await setSobrietyDate(db, parsed);
    await appSecureStorage.delete(key: _legacyDeviceKey);
    await appSecureStorage.delete(key: _legacyStorageKey);
    return parsed;
  }

  /// Persists [date] as the sobriety start date (time component ignored).
  static Future<void> setSobrietyDate(AppDatabase db, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    await db.into(db.userSettings).insertOnConflictUpdate(
          UserSettingsCompanion.insert(
            id: const Value(_settingsRowId),
            sobrietyDate: Value(dateOnly),
          ),
        );
  }

  /// Removes the stored sobriety date.
  static Future<void> clear(AppDatabase db) async {
    await db.into(db.userSettings).insertOnConflictUpdate(
          const UserSettingsCompanion(
            id: Value(_settingsRowId),
            sobrietyDate: Value(null),
          ),
        );
    await appSecureStorage.delete(key: _legacyDeviceKey);
    await appSecureStorage.delete(key: _legacyStorageKey);
  }

  // ── Calculations ────────────────────────────────────────────────────────────

  /// Number of whole calendar days between [sobrietyDate] and today.
  static int daysSober(DateTime sobrietyDate) {
    final start = _dateOnly(sobrietyDate);
    final today = _dateOnly(DateTime.now());
    final diff = today.difference(start).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// The next milestone after [days], or null if no milestone in the table.
  static SobrietyMilestone? nextMilestone(int days) {
    for (final m in SobrietyMilestone.values) {
      if (days < m.days) return m;
    }
    return null;
  }

  /// The highest milestone reached at or below [days], or null if none.
  static SobrietyMilestone? currentMilestone(int days) {
    SobrietyMilestone? result;
    for (final m in SobrietyMilestone.values) {
      if (days >= m.days) result = m;
    }
    return result;
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}

// ── Milestone table ─────────────────────────────────────────────────────────

enum SobrietyMilestone {
  thirtyDays(30,    '30 days',   '30 Days'),
  sixtyDays(60,     '60 days',   '60 Days'),
  ninetyDays(90,    '90 days',   '90 Days'),
  sixMonths(180,    '6 months',  '6 Months'),
  nineMonths(270,   '9 months',  '9 Months'),
  oneYear(365,      '1 year',    '1 Year'),
  eighteenMonths(548,  '18 months', '18 Months'),
  twoYears(730,     '2 years',   '2 Years'),
  threeYears(1095,  '3 years',   '3 Years'),
  fiveYears(1825,   '5 years',   '5 Years'),
  tenYears(3650,    '10 years',  '10 Years');

  const SobrietyMilestone(this.days, this.label, this.shortLabel);

  final int days;
  final String label;
  final String shortLabel;
}
