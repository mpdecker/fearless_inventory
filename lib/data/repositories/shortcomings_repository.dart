import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

final shortcomingRepositoryProvider =
    Provider((ref) => ShortcomingRepository(ref.read(databaseProvider)));

class ShortcomingRepository {
  final AppDatabase _db;
  ShortcomingRepository(this._db);

  /// All shortcoming logs, most recent first.
  Stream<List<ShortcomingLog>> watchAll() =>
      (_db.select(_db.shortcomingLogs)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.dateObserved, mode: OrderingMode.desc)
            ]))
          .watch();

  /// Shortcoming logs that belong to a specific defect.
  Stream<List<ShortcomingLog>> watchByDefect(int defectId) =>
      (_db.select(_db.shortcomingLogs)
            ..where((t) => t.defectId.equals(defectId))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.dateObserved, mode: OrderingMode.desc)
            ]))
          .watch();

  /// Logs with no defect link (catch-all entries).
  Stream<List<ShortcomingLog>> watchUnlinked() =>
      (_db.select(_db.shortcomingLogs)
            ..where((t) => t.defectId.isNull())
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.dateObserved, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<int> insert(ShortcomingLogsCompanion entry) =>
      _db.into(_db.shortcomingLogs).insert(entry);

  Future<bool> update(ShortcomingLog entry) =>
      _db.update(_db.shortcomingLogs).replace(entry);

  Future<void> delete(int id) =>
      (_db.delete(_db.shortcomingLogs)..where((t) => t.id.equals(id))).go();

  // ── Step 4 feed ───────────────────────────────────────────────────────────
  // Returns unique, non-empty myPart phrases from all Step 4 tables so the
  // user can draw on them as raw material when naming a shortcoming instance.
  Future<List<String>> fetchStep4MyPartPhrases() async {
    final resentments = await _db.select(_db.resentments).get();
    final fears = await _db.select(_db.fears).get();
    final harms = await _db.select(_db.harms).get();

    final all = [
      ...resentments.map((r) => r.myPart.trim()),
      ...fears.map((f) => f.myPart.trim()),
      ...harms.map((h) => h.myPart.trim()),
    ].where((s) => s.isNotEmpty).toSet().toList()
      ..sort();

    return all;
  }
}
