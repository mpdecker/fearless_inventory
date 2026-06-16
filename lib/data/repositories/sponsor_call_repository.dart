import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

class SponsorCallRepository {
  final AppDatabase _db;
  SponsorCallRepository(this._db);

  /// Record that a sponsor call happened.
  ///
  /// [scheduledFor] is the datetime the reminder was set to fire; pass null
  /// when logging a call manually (no reminder triggered it).
  Future<void> logCall({
    DateTime? scheduledFor,
    required DateTime confirmedAt,
    bool calledViaApp = false,
    String? notes,
  }) =>
      _db.into(_db.sponsorCallLogs).insert(SponsorCallLogsCompanion(
            scheduledFor: Value(scheduledFor),
            confirmedAt: Value(confirmedAt),
            calledViaApp: Value(calledViaApp),
            notes: Value(notes),
          ));

  /// All logs within the last [days] days, newest first.
  ///
  /// Date filtering is applied in Dart after fetching because Drift 2.x does
  /// not expose comparison operators on DateTimeColumn directly.
  Future<List<SponsorCallLog>> getRecentLogs(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final all = await (_db.select(_db.sponsorCallLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.confirmedAt)]))
        .get();
    return all.where((l) => !l.confirmedAt.isBefore(cutoff)).toList();
  }

  /// All logs in [start, end), newest first.
  Future<List<SponsorCallLog>> getLogsInRange(
      DateTime start, DateTime end) async {
    final all = await (_db.select(_db.sponsorCallLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.confirmedAt)]))
        .get();
    return all
        .where((l) =>
            !l.confirmedAt.isBefore(start) && l.confirmedAt.isBefore(end))
        .toList();
  }

  /// The most recent logged call, or null if none exists.
  Future<SponsorCallLog?> getLastCall() async {
    final rows = await (_db.select(_db.sponsorCallLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.confirmedAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Watch the most recent logged call as a live stream.
  Stream<SponsorCallLog?> watchLastCall() {
    return (_db.select(_db.sponsorCallLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.confirmedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }
}

final sponsorCallRepositoryProvider = Provider<SponsorCallRepository>((ref) {
  return SponsorCallRepository(ref.watch(databaseProvider));
});
