import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

final serviceCommitmentsRepositoryProvider = Provider(
    (ref) => ServiceCommitmentsRepository(ref.read(databaseProvider)));

class ServiceCommitmentsRepository {
  final AppDatabase _db;
  ServiceCommitmentsRepository(this._db);

  // ── ServiceCommitments ─────────────────────────────────────────────────────

  /// All commitments ordered by start date, active ones first.
  Stream<List<ServiceCommitment>> watchAll() =>
      (_db.select(_db.serviceCommitments)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.isActive, mode: OrderingMode.desc),
              (t) => OrderingTerm(
                  expression: t.startDate, mode: OrderingMode.asc),
            ]))
          .watch();

  /// Only active commitments.
  Stream<List<ServiceCommitment>> watchActive() =>
      (_db.select(_db.serviceCommitments)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.startDate, mode: OrderingMode.asc),
            ]))
          .watch();

  /// Past/inactive commitments.
  Stream<List<ServiceCommitment>> watchHistory() =>
      (_db.select(_db.serviceCommitments)
            ..where((t) => t.isActive.equals(false))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.startDate, mode: OrderingMode.desc),
            ]))
          .watch();

  Future<int> insertCommitment(ServiceCommitmentsCompanion entry) =>
      _db.into(_db.serviceCommitments).insert(entry);

  Future<bool> updateCommitment(ServiceCommitment entry) =>
      _db.update(_db.serviceCommitments).replace(entry);

  Future<void> deleteCommitment(int id) =>
      (_db.delete(_db.serviceCommitments)..where((t) => t.id.equals(id))).go();

  Future<void> setActive(int id, {required bool value}) =>
      (_db.update(_db.serviceCommitments)..where((t) => t.id.equals(id)))
          .write(ServiceCommitmentsCompanion(isActive: Value(value)));

  // ── TwelfthStepCalls ───────────────────────────────────────────────────────

  /// All calls (past + future), most recent first.
  Stream<List<TwelfthStepCall>> watchCalls() =>
      (_db.select(_db.twelfthStepCalls)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.occurredAt, mode: OrderingMode.desc),
            ]))
          .watch();

  /// Only future planned calls (scheduledAt is set and in the future).
  Stream<List<TwelfthStepCall>> watchScheduledCalls() {
    final now = DateTime.now();
    return watchCalls().map((all) => all
        .where((c) =>
            c.scheduledAt != null && c.scheduledAt!.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!)));
  }

  /// Only completed / already-happened calls.
  Stream<List<TwelfthStepCall>> watchPastCalls() {
    final now = DateTime.now();
    return watchCalls().map((all) => all
        .where((c) =>
            c.scheduledAt == null || !c.scheduledAt!.isAfter(now))
        .toList());
  }

  /// All calls linked to a specific sponsee.
  Stream<List<TwelfthStepCall>> watchCallsForSponsee(int sponseeId) =>
      watchCalls().map((all) =>
          all.where((c) => c.sponseeId == sponseeId).toList());

  Future<int> insertCall(TwelfthStepCallsCompanion entry) =>
      _db.into(_db.twelfthStepCalls).insert(entry);

  Future<bool> updateCall(TwelfthStepCall entry) =>
      _db.update(_db.twelfthStepCalls).replace(entry);

  Future<void> deleteCall(int id) =>
      (_db.delete(_db.twelfthStepCalls)..where((t) => t.id.equals(id))).go();

  /// Mark a scheduled call as completed (clears scheduledAt, sets occurredAt
  /// to now so it rolls into the history section).
  Future<void> completeScheduledCall(int id) {
    final now = DateTime.now();
    return (_db.update(_db.twelfthStepCalls)..where((t) => t.id.equals(id)))
        .write(TwelfthStepCallsCompanion(
          occurredAt: Value(now),
          scheduledAt: const Value(null),
        ));
  }

  // ── Stats helpers ──────────────────────────────────────────────────────────

  /// Count of active commitments — used by stats cards.
  Stream<int> watchActiveCount() => watchActive()
      .map((list) => list.length);

  /// Count of step-12 calls logged this calendar month.
  Stream<int> watchCallsThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return watchCalls().map((calls) => calls
        .where((c) =>
            !c.occurredAt.isBefore(start) && c.occurredAt.isBefore(end))
        .length);
  }
}
