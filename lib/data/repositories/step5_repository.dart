import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

final step5RepositoryProvider =
    Provider((ref) => Step5Repository(ref.read(databaseProvider)));

class Step5Repository {
  final AppDatabase _db;
  Step5Repository(this._db);

  /// Stream of all Step 5 completions, most recent first.
  Stream<List<Step5Completion>> watchAll() =>
      (_db.select(_db.step5Completions)
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .watch();

  /// Returns the single most recent completion, or null if Step 5 has
  /// never been completed.
  Future<Step5Completion?> latestCompletion() async {
    final results = await (_db.select(_db.step5Completions)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// Saves a completed Step 5 record. Returns the new row id.
  Future<int> recordCompletion({
    required bool admittedToSelf,
    required bool admittedToHigherPower,
    required bool admittedToSponsor,
    String? reflection,
    required int resentmentCount,
    required int fearCount,
    required int harmCount,
  }) =>
      _db.into(_db.step5Completions).insert(
            Step5CompletionsCompanion(
              admittedToSelf: Value(admittedToSelf),
              admittedToHigherPower: Value(admittedToHigherPower),
              admittedToSponsor: Value(admittedToSponsor),
              reflection: Value(reflection),
              resentmentCount: Value(resentmentCount),
              fearCount: Value(fearCount),
              harmCount: Value(harmCount),
              completedAt: Value(DateTime.now()),
            ),
          );
}
