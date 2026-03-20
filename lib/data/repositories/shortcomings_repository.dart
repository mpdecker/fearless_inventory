import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

// Ensure this matches the provider name used in the dashboard
final shortcomingRepositoryProvider = Provider((ref) => ShortcomingRepository(ref.read(databaseProvider)));

class ShortcomingRepository {
  final AppDatabase _db;
  ShortcomingRepository(this._db);

  Stream<List<ShortcomingLog>> watchAll() => _db.select(_db.shortcomingLogs).watch();

  Future<int> insert(ShortcomingLogsCompanion entry) => _db.into(_db.shortcomingLogs).insert(entry);

  Future<void> delete(int id) => 
      (_db.delete(_db.shortcomingLogs)..where((t) => t.id.equals(id))).go();
}