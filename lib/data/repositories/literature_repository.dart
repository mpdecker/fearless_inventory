import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

final literatureRepositoryProvider = Provider<LiteratureRepository>((ref) {
  return LiteratureRepository(ref.watch(databaseProvider));
});

class LiteratureRepository {
  final AppDatabase _db;
  LiteratureRepository(this._db);

  // ── Watch ─────────────────────────────────────────────────────────────────

  /// All bookmarks, most recent first.
  Stream<List<LiteratureBookmark>> watchAll() =>
      (_db.select(_db.literatureBookmarks)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Bookmarks for a specific book ('bigbook' | 'twelve_twelve').
  Stream<List<LiteratureBookmark>> watchForBook(String bookKey) =>
      (_db.select(_db.literatureBookmarks)
            ..where((t) => t.bookKey.equals(bookKey))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Adds a bookmark for [chapterKey] (no-op if already bookmarked).
  Future<void> bookmark({
    required String bookKey,
    required String chapterKey,
    required String chapterTitle,
    String? note,
  }) =>
      _db.into(_db.literatureBookmarks).insertOnConflictUpdate(
            LiteratureBookmarksCompanion.insert(
              bookKey: bookKey,
              chapterKey: chapterKey,
              chapterTitle: chapterTitle,
              note: Value(note),
            ),
          );

  /// Removes the bookmark for [chapterKey] (no-op if not bookmarked).
  Future<void> removeBookmark({
    required String bookKey,
    required String chapterKey,
  }) =>
      (_db.delete(_db.literatureBookmarks)
            ..where((t) =>
                t.bookKey.equals(bookKey) & t.chapterKey.equals(chapterKey)))
          .go();

  /// True if [chapterKey] is currently bookmarked.
  Future<bool> isBookmarked({
    required String bookKey,
    required String chapterKey,
  }) async {
    final row = await (_db.select(_db.literatureBookmarks)
          ..where((t) =>
              t.bookKey.equals(bookKey) & t.chapterKey.equals(chapterKey)))
        .getSingleOrNull();
    return row != null;
  }
}
