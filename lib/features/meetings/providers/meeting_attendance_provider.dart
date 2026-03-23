import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/meetings_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Attendance stats model
// ─────────────────────────────────────────────────────────────────────────────

class AttendanceStats {
  /// Total lifetime meetings attended
  final int lifetimeCount;

  /// How many in the last 30 days
  final int last30Days;

  /// How many in the last 7 days
  final int last7Days;

  /// Longest gap (in days) between meetings in the last 90 days, or null
  final int? longestGapDays;

  /// How many times the user shared at a meeting (lifetime)
  final int timesShared;

  const AttendanceStats({
    required this.lifetimeCount,
    required this.last30Days,
    required this.last7Days,
    this.longestGapDays,
    required this.timesShared,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final meetingAttendanceStatsProvider =
    StreamProvider.autoDispose<AttendanceStats>((ref) {
  final repo = ref.watch(meetingsRepositoryProvider);
  return repo.watchAttendance().map((logs) {
    final now = DateTime.now();
    final cutoff30 = now.subtract(const Duration(days: 30));
    final cutoff7 = now.subtract(const Duration(days: 7));
    final cutoff90 = now.subtract(const Duration(days: 90));

    final recent90 = logs
        .where((l) => l.attendedAt.isAfter(cutoff90))
        .toList()
      ..sort((a, b) => a.attendedAt.compareTo(b.attendedAt));

    // Compute longest gap within the last 90 days
    int? longestGap;
    for (var i = 1; i < recent90.length; i++) {
      final gap = recent90[i]
          .attendedAt
          .difference(recent90[i - 1].attendedAt)
          .inDays;
      if (longestGap == null || gap > longestGap) longestGap = gap;
    }

    return AttendanceStats(
      lifetimeCount: logs.length,
      last30Days:
          logs.where((l) => l.attendedAt.isAfter(cutoff30)).length,
      last7Days: logs.where((l) => l.attendedAt.isAfter(cutoff7)).length,
      longestGapDays: longestGap,
      timesShared: logs.where((l) => l.sharedAtMeeting).length,
    );
  });
});
