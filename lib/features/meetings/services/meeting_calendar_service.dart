import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../data/repositories/step12_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Computes the next wall-clock [DateTime] when [weekday] (0 = Sunday …
/// 6 = Saturday) falls, at the time given by [startTime] ("HH:mm").
///
/// If [from] is omitted, [DateTime.now()] is used.
DateTime nextMeetingOccurrence(
  int weekday,
  String startTime, {
  DateTime? from,
}) {
  final base = from ?? DateTime.now();
  final parts = startTime.split(':');
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

  // Dart weekday: Mon=1 … Sun=7
  // Meeting weekday: Sun=0, Mon=1 … Sat=6  →  Sun maps to 7 in Dart.
  final dartTarget = weekday == 0 ? 7 : weekday;
  var daysAhead = dartTarget - base.weekday;
  if (daysAhead < 0) daysAhead += 7;

  final candidate =
      DateTime(base.year, base.month, base.day + daysAhead, h, m);

  // If the candidate time is already in the past today, push a week ahead.
  return candidate.isBefore(base)
      ? candidate.add(const Duration(days: 7))
      : candidate;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final meetingCalendarServiceProvider = Provider<MeetingCalendarService>((ref) {
  return MeetingCalendarService(ref.watch(step12RepositoryProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class MeetingCalendarService {
  final Step12Repository _repo;
  MeetingCalendarService(this._repo);

  // ── Single occurrence ────────────────────────────────────────────────────

  /// Inserts one Step 12 calendar event for the meeting's *next* occurrence.
  Future<void> addSingle(Meeting m) async {
    final start = nextMeetingOccurrence(m.weekday, m.startTime);
    final end = start.add(Duration(minutes: m.durationMinutes ?? 60));
    await _repo.insert(StepTwelveEventsCompanion(
      title: Value(m.name),
      description: Value(_desc(m)),
      location: Value(_loc(m)),
      startTime: Value(start),
      endTime: Value(end),
      eventType: const Value('meeting'),
    ));
  }

  // ── Recurring ────────────────────────────────────────────────────────────

  /// Inserts [weeks] weekly Step 12 events starting from the next occurrence.
  /// Returns the number of events added.
  Future<int> addRecurring(Meeting m, {int weeks = 12}) async {
    DateTime start = nextMeetingOccurrence(m.weekday, m.startTime);
    for (var i = 0; i < weeks; i++) {
      final end = start.add(Duration(minutes: m.durationMinutes ?? 60));
      await _repo.insert(StepTwelveEventsCompanion(
        title: Value(m.name),
        description: Value(_desc(m)),
        location: Value(_loc(m)),
        startTime: Value(start),
        endTime: Value(end),
        eventType: const Value('meeting'),
      ));
      start = start.add(const Duration(days: 7));
    }
    return weeks;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _loc(Meeting m) {
    if (m.address != null) return '${m.address}, ${m.city}';
    if (m.locationName != null) return '${m.locationName}, ${m.city}';
    return m.city;
  }

  String _desc(Meeting m) {
    final lines = <String>[];
    if (m.locationName != null) lines.add(m.locationName!);
    if (m.address != null) lines.add(m.address!);
    if (m.conferenceUrl != null) lines.add('Join: ${m.conferenceUrl}');
    if (m.conferencePhone != null) lines.add('Phone: ${m.conferencePhone}');
    if (m.notes != null && m.notes!.isNotEmpty) lines.add(m.notes!);
    return lines.join('\n');
  }
}
