import 'app_secure_storage.dart';

/// Persists the user's sobriety date using the same encrypted secure storage
/// as the onboarding flag and database key.
///
/// The date is stored as an ISO-8601 date string (YYYY-MM-DD) so it is
/// timezone-independent — we only care about calendar days, not time.
///
/// Storage key is [storageKey]; legacy installs used `sobriety_date_v1`.
class SobrietyService {
  static const storageKey = 'fearless_sobriety_date';
  static const _legacyStorageKey = 'sobriety_date_v1';

  /// Returns the stored sobriety date, or null if not yet set.
  static Future<DateTime?> getSobrietyDate() async {
    var val = await appSecureStorage.read(key: storageKey);
    val ??= await appSecureStorage.read(key: _legacyStorageKey);
    if (val == null) return null;
    return DateTime.tryParse(val);
  }

  /// Persists [date] as the sobriety start date (time component ignored).
  static Future<void> setSobrietyDate(DateTime date) async {
    final iso =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    await appSecureStorage.write(key: storageKey, value: iso);
    await appSecureStorage.delete(key: _legacyStorageKey);
  }

  /// Removes the stored sobriety date.
  static Future<void> clear() async {
    await appSecureStorage.delete(key: storageKey);
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
