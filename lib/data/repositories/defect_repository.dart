import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

final defectRepositoryProvider = Provider((ref) => DefectRepository(ref.read(databaseProvider)));

class DefectRepository {
  final AppDatabase _db;
  DefectRepository(this._db);

  Stream<List<Defect>> watchAll() => _db.select(_db.defects).watch();

  Future<int> insert(DefectsCompanion entry) => _db.into(_db.defects).insert(entry);

  Future<bool> updateDefect(Defect defect) => _db.update(_db.defects).replace(defect);

  Future<void> delete(int id) =>
      (_db.delete(_db.defects)..where((t) => t.id.equals(id))).go();

  /// Returns the id of the defect whose name matches [name] (case-insensitive),
  /// creating a new record if none exists yet.
  Future<int> findOrCreateByName(String name) async {
    final trimmed = name.trim();
    final rows = await _db.select(_db.defects).get();
    for (final d in rows) {
      if (d.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        return d.id;
      }
    }
    // Not found — insert and return new id.
    return insert(DefectsCompanion(
      name: Value(trimmed),
      createdAt: Value(DateTime.now()),
    ));
  }
}