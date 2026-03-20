import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

// Provider definition for the repository
final amendsRepositoryProvider = Provider((ref) => AmendsRepository(ref.read(databaseProvider)));

class AmendsRepository {
  final AppDatabase _db;
  AmendsRepository(this._db);

  // Stream used by the amendsListProvider
  Stream<List<Amend>> watchAll() => _db.select(_db.amends).watch();

  Future<int> insert(AmendsCompanion entry) => _db.into(_db.amends).insert(entry);
  
  Future<void> delete(int id) => (_db.delete(_db.amends)..where((t) => t.id.equals(id))).go();
}