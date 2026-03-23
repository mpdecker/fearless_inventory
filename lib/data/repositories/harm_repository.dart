import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

final harmRepositoryProvider = Provider((ref) => HarmRepository(ref));

class HarmRepository {
  final Ref _ref;
  HarmRepository(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  Stream<List<Harm>> watchAllHarms() => _db.select(_db.harms).watch();

  Future<int> insertHarm(HarmsCompanion entry) => _db.into(_db.harms).insert(entry);

  Future<bool> updateHarm(Harm entry) => _db.update(_db.harms).replace(entry);

  Future<int> deleteHarm(int id) => 
    (_db.delete(_db.harms)..where((t) => t.id.equals(id))).go();
}