import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

final sponseeRepositoryProvider =
    Provider((ref) => SponseeRepository(ref.read(databaseProvider)));

class SponseeRepository {
  final AppDatabase _db;
  SponseeRepository(this._db);

  // ── Sponsees ──────────────────────────────────────────────────────────────

  /// All sponsees, active first then alphabetically.
  Stream<List<Sponsee>> watchAll() =>
      (_db.select(_db.sponsees)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.isActive, mode: OrderingMode.desc),
              (t) => OrderingTerm(
                  expression: t.name, mode: OrderingMode.asc),
            ]))
          .watch();

  Stream<List<Sponsee>> watchActive() =>
      (_db.select(_db.sponsees)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.name, mode: OrderingMode.asc),
            ]))
          .watch();

  Future<Sponsee?> getById(int id) =>
      (_db.select(_db.sponsees)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertSponsee(SponseesCompanion entry) =>
      _db.into(_db.sponsees).insert(entry);

  Future<bool> updateSponsee(Sponsee entry) =>
      _db.update(_db.sponsees).replace(entry);

  Future<void> deleteSponsee(int id) =>
      (_db.delete(_db.sponsees)..where((t) => t.id.equals(id))).go();

  Future<void> setActive(int id, {required bool value}) =>
      (_db.update(_db.sponsees)..where((t) => t.id.equals(id)))
          .write(SponseesCompanion(isActive: Value(value)));

  Future<void> setCurrentStep(int id, int? step) =>
      (_db.update(_db.sponsees)..where((t) => t.id.equals(id)))
          .write(SponseesCompanion(currentStep: Value(step)));

  // ── SponseeStepProgress ───────────────────────────────────────────────────

  /// All step entries for a given sponsee, ordered by step number.
  Stream<List<SponseeStepEntry>> watchStepProgress(int sponseeId) =>
      (_db.select(_db.sponseeStepProgress)
            ..where((t) => t.sponseeId.equals(sponseeId))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.stepNumber, mode: OrderingMode.asc),
            ]))
          .watch();

  /// Upsert a step entry — insert or update by (sponseeId, stepNumber).
  Future<void> upsertStep(SponseeStepProgressCompanion entry) =>
      _db.into(_db.sponseeStepProgress).insertOnConflictUpdate(entry);

  Future<void> updateStepStatus(
    int sponseeId,
    int stepNumber,
    String status, {
    DateTime? completedAt,
    String? notes,
  }) async {
    final existing = await (_db.select(_db.sponseeStepProgress)
          ..where((t) =>
              t.sponseeId.equals(sponseeId) &
              t.stepNumber.equals(stepNumber)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.sponseeStepProgress).insert(
            SponseeStepProgressCompanion(
              sponseeId: Value(sponseeId),
              stepNumber: Value(stepNumber),
              status: Value(status),
              completedAt: Value(completedAt),
              notes: Value(notes),
            ),
          );
    } else {
      await (_db.update(_db.sponseeStepProgress)
            ..where((t) =>
                t.sponseeId.equals(sponseeId) &
                t.stepNumber.equals(stepNumber)))
          .write(SponseeStepProgressCompanion(
            status: Value(status),
            completedAt: Value(completedAt),
            notes: notes != null ? Value(notes) : const Value.absent(),
          ));
    }
  }

  // ── SponseeCheckIns ───────────────────────────────────────────────────────

  /// All check-ins for a sponsee, most recent first.
  Stream<List<SponseeCheckIn>> watchCheckIns(int sponseeId) =>
      (_db.select(_db.sponseeCheckIns)
            ..where((t) => t.sponseeId.equals(sponseeId))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.scheduledAt, mode: OrderingMode.desc),
            ]))
          .watch();

  /// Upcoming (incomplete) check-ins for a sponsee.
  Stream<List<SponseeCheckIn>> watchUpcomingCheckIns(int sponseeId) {
    final now = DateTime.now();
    return watchCheckIns(sponseeId).map((all) => all
        .where((c) =>
            c.completedAt == null && c.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)));
  }

  Future<int> insertCheckIn(SponseeCheckInsCompanion entry) =>
      _db.into(_db.sponseeCheckIns).insert(entry);

  Future<bool> updateCheckIn(SponseeCheckIn entry) =>
      _db.update(_db.sponseeCheckIns).replace(entry);

  Future<void> deleteCheckIn(int id) =>
      (_db.delete(_db.sponseeCheckIns)..where((t) => t.id.equals(id))).go();

  Future<void> completeCheckIn(int id, {String? notes}) =>
      (_db.update(_db.sponseeCheckIns)..where((t) => t.id.equals(id)))
          .write(SponseeCheckInsCompanion(
            completedAt: Value(DateTime.now()),
            notes: notes != null ? Value(notes) : const Value.absent(),
          ));

  // ── Stats ─────────────────────────────────────────────────────────────────

  Stream<int> watchActiveCount() =>
      watchActive().map((list) => list.length);
}
