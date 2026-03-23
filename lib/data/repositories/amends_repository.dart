import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

final amendsRepositoryProvider =
    Provider((ref) => AmendsRepository(ref.read(databaseProvider)));

class AmendsRepository {
  final AppDatabase _db;
  AmendsRepository(this._db);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream of all amends entries, ordered by creation date descending.
  Stream<List<Amend>> watchAll() =>
      (_db.select(_db.amends)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Stream filtered to a specific status value ('step8' | 'pending' | 'completed').
  Stream<List<Amend>> watchByStatus(String status) =>
      (_db.select(_db.amends)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm.asc(t.person)]))
          .watch();

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<int> insert(AmendsCompanion entry) =>
      _db.into(_db.amends).insert(entry);

  /// Full replacement update — replaces the entire row identified by entry.id.
  Future<bool> update(Amend entry) =>
      _db.update(_db.amends).replace(entry);

  /// Partial update: toggle completion status without touching other fields.
  Future<void> toggleCompleted(int id, bool isCompleted) =>
      (_db.update(_db.amends)..where((t) => t.id.equals(id))).write(
        AmendsCompanion(
          status: Value(isCompleted ? 'completed' : 'pending'),
          dateCompleted: Value(isCompleted ? DateTime.now() : null),
        ),
      );

  Future<void> delete(int id) =>
      (_db.delete(_db.amends)..where((t) => t.id.equals(id))).go();
}
