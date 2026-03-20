import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';

final reviewRepositoryProvider = Provider((ref) => ReviewRepository(ref.read(databaseProvider)));

class ReviewRepository {
  final AppDatabase _db;
  ReviewRepository(this._db);

  Stream<List<DailyReview>> watchAllReviews() => 
      (_db.select(_db.dailyReviews)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
}