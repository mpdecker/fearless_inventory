import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

final resentmentRepositoryProvider = Provider((ref) => ResentmentRepository(ref));

class ResentmentRepository {
  final Ref _ref;
  ResentmentRepository(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  Stream<List<Resentment>> watchAllResentments() =>
      _db.select(_db.resentments).watch();

  Future<int> insertResentment(ResentmentsCompanion entry) =>
      _db.into(_db.resentments).insert(entry);

  Future<bool> updateResentment(Resentment entry) =>
      _db.update(_db.resentments).replace(entry);

  Future<int> deleteResentment(int id) =>
      (_db.delete(_db.resentments)..where((t) => t.id.equals(id))).go();
}
