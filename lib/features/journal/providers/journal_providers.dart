import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/journal_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// All entries
// ─────────────────────────────────────────────────────────────────────────────

/// Stream of all journal entries, newest first.
final allJournalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  return ref.watch(journalRepositoryProvider).watchAll();
});

/// Total entry count — shown in tab badges and export dialogs.
final journalTotalCountProvider = StreamProvider<int>((ref) {
  return ref.watch(journalRepositoryProvider).watchTotalCount();
});

// ─────────────────────────────────────────────────────────────────────────────
// Per-step / per-tradition streams
// ─────────────────────────────────────────────────────────────────────────────

/// Entries for a specific step number (1–12), newest first.
final stepJournalEntriesProvider =
    StreamProvider.autoDispose.family<List<JournalEntry>, int>((ref, step) {
  return ref.watch(journalRepositoryProvider).watchByStep(step);
});

/// Entries for a specific tradition number (1–12), newest first.
final traditionJournalEntriesProvider =
    StreamProvider.autoDispose.family<List<JournalEntry>, int>(
        (ref, tradition) {
  return ref.watch(journalRepositoryProvider).watchByTradition(tradition);
});

/// Entry count for a specific step — used by the grid card badge.
final stepEntryCountProvider =
    StreamProvider.autoDispose.family<int, int>((ref, step) {
  return ref.watch(journalRepositoryProvider).watchCountForStep(step);
});

/// Entry count for a specific tradition — used by the grid card badge.
final traditionEntryCountProvider =
    StreamProvider.autoDispose.family<int, int>((ref, tradition) {
  return ref.watch(journalRepositoryProvider).watchCountForTradition(tradition);
});
