import 'package:drift/drift.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';

final step12RepositoryProvider =
    Provider((ref) => Step12Repository(ref.read(databaseProvider)));

class Step12Repository {
  final AppDatabase _db;
  Step12Repository(this._db);

  /// All events ordered by start time ascending.
  Stream<List<StepTwelveEvent>> watchAll() =>
      (_db.select(_db.stepTwelveEvents)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.startTime, mode: OrderingMode.asc)
            ]))
          .watch();

  /// Events in a given calendar month (for lighter loads if needed).
  Stream<List<StepTwelveEvent>> watchMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return watchAll().map((events) => events
        .where((e) =>
            !e.startTime.isBefore(start) && e.startTime.isBefore(end))
        .toList());
  }

  Future<int> insert(StepTwelveEventsCompanion entry) =>
      _db.into(_db.stepTwelveEvents).insert(entry);

  Future<bool> update(StepTwelveEvent entry) =>
      _db.update(_db.stepTwelveEvents).replace(entry);

  Future<void> delete(int id) =>
      (_db.delete(_db.stepTwelveEvents)
            ..where((t) => t.id.equals(id)))
          .go();
}
