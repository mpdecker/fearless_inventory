import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/database/database.dart';

final meditationRepositoryProvider = Provider((ref) => MeditationRepository(ref));

class MeditationRepository {
  final Ref _ref;
  MeditationRepository(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  Stream<List<Meditation>> watchAll() => 
      (_db.select(_db.meditations)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<int> insert(MeditationsCompanion entry) => _db.into(_db.meditations).insert(entry);
}