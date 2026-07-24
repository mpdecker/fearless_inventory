import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';

final literatureAnnotationRepositoryProvider =
    Provider<LiteratureAnnotationRepository>((ref) {
  return LiteratureAnnotationRepository(ref.watch(databaseProvider));
});

/// Highlights and notes anchored to character ranges in literature sections.
class LiteratureAnnotationRepository {
  final AppDatabase _db;
  LiteratureAnnotationRepository(this._db);

  // ── Watch ─────────────────────────────────────────────────────────────────

  /// Annotations for one section, ordered by where they appear in the text.
  Stream<List<LiteratureAnnotation>> watchForSection({
    required String bookKey,
    required int startPage,
    required int endPage,
  }) =>
      (_db.select(_db.literatureAnnotations)
            ..where((t) =>
                t.bookKey.equals(bookKey) &
                t.startPage.equals(startPage) &
                t.endPage.equals(endPage))
            ..orderBy([(t) => OrderingTerm.asc(t.selectionStart)]))
          .watch();

  /// All annotations for a book, most recent first (for a book-wide list).
  Stream<List<LiteratureAnnotation>> watchForBook(String bookKey) =>
      (_db.select(_db.literatureAnnotations)
            ..where((t) => t.bookKey.equals(bookKey))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  /// Every annotation, most recent first.
  Stream<List<LiteratureAnnotation>> watchAll() =>
      (_db.select(_db.literatureAnnotations)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Creates a highlight (optionally with a [note]) and returns its row id.
  Future<int> add({
    required String bookKey,
    required int startPage,
    required int endPage,
    required String sectionTitle,
    required int selectionStart,
    required int selectionEnd,
    required String selectedText,
    String color = 'yellow',
    String? note,
  }) {
    return _db.into(_db.literatureAnnotations).insert(
          LiteratureAnnotationsCompanion.insert(
            bookKey: bookKey,
            startPage: startPage,
            endPage: endPage,
            sectionTitle: sectionTitle,
            selectionStart: selectionStart,
            selectionEnd: selectionEnd,
            selectedText: selectedText,
            color: Value(color),
            note: Value(note),
          ),
        );
  }

  /// Sets (or clears, when [note] is null/empty) the note on an annotation.
  Future<void> setNote(int id, String? note) {
    final trimmed = note?.trim();
    return (_db.update(_db.literatureAnnotations)..where((t) => t.id.equals(id)))
        .write(
      LiteratureAnnotationsCompanion(
        note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Changes the highlight colour.
  Future<void> setColor(int id, String color) {
    return (_db.update(_db.literatureAnnotations)..where((t) => t.id.equals(id)))
        .write(
      LiteratureAnnotationsCompanion(
        color: Value(color),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes the annotation.
  Future<void> delete(int id) =>
      (_db.delete(_db.literatureAnnotations)..where((t) => t.id.equals(id)))
          .go();
}
