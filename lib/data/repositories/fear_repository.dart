import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

final fearRepositoryProvider = Provider((ref) => FearRepository(ref));

class FearRepository {
  final Ref _ref;
  FearRepository(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  Stream<List<Fear>> watchAllFears() => _db.select(_db.fears).watch();

  Future<int> insertFear(FearsCompanion entry) => _db.into(_db.fears).insert(entry);

  Future<bool> updateFear(Fear entry) => _db.update(_db.fears).replace(entry);

  Future<int> deleteFear(int id) => 
    (_db.delete(_db.fears)..where((t) => t.id.equals(id))).go();
}