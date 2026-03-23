import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode, Value;
import '../../core/database/database.dart';
import '../services/reflection_service.dart' show ReflectionService;

final meditationRepositoryProvider =
    Provider((ref) => MeditationRepository(ref));

class MeditationRepository {
  final Ref _ref;
  MeditationRepository(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  // ── Session persistence ───────────────────────────────────────────────────

  /// Records a completed meditation session.
  ///
  /// [sessionType]     'morning' | 'evening'
  /// [reflectionTheme] The CSV theme that was surfaced (e.g. 'courage').
  /// [reflectionKey]   First 80 chars of the reflection quote — stable
  ///                   fingerprint used for recency weighting next time.
  /// [durationSeconds] Seconds spent on the timer (0 if timer not used).
  Future<void> saveSession({
    required String sessionType,
    required String reflectionTheme,
    required String reflectionKey,
    required int durationSeconds,
  }) =>
      _db.into(_db.meditationSessions).insert(
            MeditationSessionsCompanion.insert(
              sessionType: sessionType,
              reflectionTheme: reflectionTheme,
              reflectionKey: reflectionKey,
              durationSeconds: Value(durationSeconds),
              completedAt: DateTime.now(),
            ),
          );

  // ── Recency map ───────────────────────────────────────────────────────────

  /// Returns a map of reflectionKey → most-recent completedAt for the
  /// [limit] most recently completed sessions.
  ///
  /// Passed to [ReflectionService.selectWeighted] so recently-surfaced
  /// passages receive a recency penalty.
  Future<Map<String, DateTime>> getRecentReflectionKeys({
    int limit = 50,
  }) async {
    final rows = await (_db.select(_db.meditationSessions)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.completedAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();

    final map = <String, DateTime>{};
    for (final row in rows) {
      // Keep only the most-recent appearance of each key
      if (!map.containsKey(row.reflectionKey)) {
        map[row.reflectionKey] = row.completedAt;
      }
    }
    return map;
  }

  // ── Theme weights from Step-10 history ───────────────────────────────────

  /// Computes per-theme weights from the last 30 days of Step-10 reviews.
  ///
  /// Each signal that fired on a given review day contributes +1.0 to
  /// every CSV theme that maps to that signal.  The resulting map is
  /// passed (along with a per-session today-boost) to
  /// [ReflectionService.selectWeighted].
  Future<Map<String, double>> getThemeWeights() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    // Drift 2.32 doesn't expose value-comparison methods for DateTimeColumn,
    // so we fetch all reviews and filter in Dart.
    final allReviews = await _db.select(_db.dailyReviews).get();
    final reviews =
        allReviews.where((r) => !r.date.isBefore(cutoff)).toList();

    final signalCounts = <String, int>{
      'resentful': 0,
      'afraid':    0,
      'dishonest': 0,
      'selfish':   0,
    };
    for (final r in reviews) {
      if (r.wasResentful) signalCounts['resentful'] = signalCounts['resentful']! + 1;
      if (r.wasAfraid)    signalCounts['afraid']    = signalCounts['afraid']!    + 1;
      if (r.wasDishonest) signalCounts['dishonest'] = signalCounts['dishonest']! + 1;
      if (r.wasSelfish)   signalCounts['selfish']   = signalCounts['selfish']!   + 1;
    }

    final weights = <String, double>{};
    for (final entry in signalCounts.entries) {
      if (entry.value == 0) continue;
      for (final theme
          in ReflectionService.signalToThemes[entry.key] ?? <String>[]) {
        weights[theme] = (weights[theme] ?? 0) + entry.value.toDouble();
      }
    }
    return weights;
  }

  // ── Aggregate time stats ──────────────────────────────────────────────────

  Future<int> _totalSecondsInRange(DateTime from, DateTime to) async {
    final allRows = await _db.select(_db.meditationSessions).get();
    final rows = allRows.where((r) =>
        !r.completedAt.isBefore(from) && r.completedAt.isBefore(to));
    return rows.fold<int>(0, (sum, r) => sum + r.durationSeconds);
  }

  Future<int> getTotalSecondsThisWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    return _totalSecondsInRange(weekStart, now);
  }

  Future<int> getTotalSecondsLastWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekStart = DateTime(monday.year, monday.month, monday.day);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    return _totalSecondsInRange(lastWeekStart, thisWeekStart);
  }

  Future<int> getDaysWithMeditationLast30() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final allRows = await _db.select(_db.meditationSessions).get();
    final days = allRows
        .where((r) => !r.completedAt.isBefore(cutoff))
        .map((r) => r.completedAt.toIso8601String().split('T').first)
        .toSet();
    return days.length;
  }
}
