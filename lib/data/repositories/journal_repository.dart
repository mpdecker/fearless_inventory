import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.read(databaseProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class JournalRepository {
  final AppDatabase _db;
  JournalRepository(this._db);

  // ── Streams ────────────────────────────────────────────────────────────────

  /// All journal entries, newest first.
  Stream<List<JournalEntry>> watchAll() {
    return (_db.select(_db.journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Entries for a specific step number, newest first.
  Stream<List<JournalEntry>> watchByStep(int stepNumber) {
    return (_db.select(_db.journalEntries)
          ..where((t) => t.stepNumber.equals(stepNumber))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Entries for a specific tradition number, newest first.
  Stream<List<JournalEntry>> watchByTradition(int traditionNumber) {
    return (_db.select(_db.journalEntries)
          ..where((t) => t.traditionNumber.equals(traditionNumber))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Count of entries for a step number.
  Stream<int> watchCountForStep(int stepNumber) {
    return watchByStep(stepNumber).map((list) => list.length);
  }

  /// Count of entries for a tradition number.
  Stream<int> watchCountForTradition(int traditionNumber) {
    return watchByTradition(traditionNumber).map((list) => list.length);
  }

  /// Total count of all journal entries.
  Stream<int> watchTotalCount() {
    return watchAll().map((list) => list.length);
  }

  // ── One-shot queries ───────────────────────────────────────────────────────

  /// All entries for PDF export, oldest first (chronological reading order).
  Future<List<JournalEntry>> getAllForExport() {
    return (_db.select(_db.journalEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<JournalEntry?> getById(int id) async {
    final results = await (_db.select(_db.journalEntries)
          ..where((t) => t.id.equals(id)))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  Future<int> insert({
    required String content,
    String? title,
    int? stepNumber,
    int? traditionNumber,
    String? promptId,
    String? mood,
    String? tags,
  }) {
    return _db.into(_db.journalEntries).insert(
          JournalEntriesCompanion(
            content: Value(content),
            title: Value(title),
            stepNumber: Value(stepNumber),
            traditionNumber: Value(traditionNumber),
            promptId: Value(promptId),
            mood: Value(mood),
            tags: Value(tags),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String content,
    String? title,
    int? stepNumber,
    int? traditionNumber,
    String? promptId,
    String? mood,
    String? tags,
  }) async {
    await (_db.update(_db.journalEntries)..where((t) => t.id.equals(id))).write(
      JournalEntriesCompanion(
        content: Value(content),
        title: Value(title),
        stepNumber: Value(stepNumber),
        traditionNumber: Value(traditionNumber),
        promptId: Value(promptId),
        mood: Value(mood),
        tags: Value(tags),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.journalEntries)..where((t) => t.id.equals(id))).go();
  }
}
