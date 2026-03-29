import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/meetings_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────

enum MeetingFormat { all, inPerson, online, hybrid }

/// Time-of-day period for filtering by meeting start time.
enum MeetingTimeOfDay {
  morning,   // 5:00 AM – 12:00 PM
  afternoon, // 12:00 PM – 5:00 PM
  evening,   // 5:00 PM – 9:00 PM
  night,     // 9:00 PM – 5:00 AM
}

extension MeetingTimeOfDayX on MeetingTimeOfDay {
  String get label => switch (this) {
        MeetingTimeOfDay.morning   => 'Morning',
        MeetingTimeOfDay.afternoon => 'Afternoon',
        MeetingTimeOfDay.evening   => 'Evening',
        MeetingTimeOfDay.night     => 'Night',
      };

  IconData get icon => switch (this) {
        MeetingTimeOfDay.morning   => Icons.wb_sunny_outlined,
        MeetingTimeOfDay.afternoon => Icons.cloud_outlined,
        MeetingTimeOfDay.evening   => Icons.brightness_5,
        MeetingTimeOfDay.night     => Icons.brightness_3,
      };

  /// Returns true if [minutesFromMidnight] falls in this period.
  bool matchesMinutes(int minutesFromMidnight) {
    final m = minutesFromMidnight;
    return switch (this) {
      MeetingTimeOfDay.morning   => m >= 300 && m < 720,   // 5 AM – 12 PM
      MeetingTimeOfDay.afternoon => m >= 720 && m < 1020,  // 12 PM – 5 PM
      MeetingTimeOfDay.evening   => m >= 1020 && m < 1260, // 5 PM – 9 PM
      MeetingTimeOfDay.night     => m >= 1260 || m < 300,  // 9 PM – 5 AM
    };
  }
}

/// Parses a JSON-encoded list of meeting type codes.
List<String> parseMeetingTypeCodes(String json) {
  try {
    return (jsonDecode(json) as List).cast<String>();
  } catch (_) {
    return [];
  }
}

/// The time-of-day bucket for the current wall-clock time.
MeetingTimeOfDay currentMeetingTimeOfDay() {
  final now = DateTime.now();
  final mins = now.hour * 60 + now.minute;
  if (mins >= 300 && mins < 720) return MeetingTimeOfDay.morning;
  if (mins >= 720 && mins < 1020) return MeetingTimeOfDay.afternoon;
  if (mins >= 1020 && mins < 1260) return MeetingTimeOfDay.evening;
  return MeetingTimeOfDay.night;
}

/// Today expressed in TSML weekday convention: 0 = Sunday … 6 = Saturday.
/// Dart's [DateTime.weekday] is 1=Mon … 7=Sun, so `weekday % 7` maps 7 → 0.
int todayWeekday() => DateTime.now().weekday % 7;

class MeetingFilter {
  final int? weekday;
  final MeetingTimeOfDay? timeOfDay;
  final Set<String> typeCodes;
  final MeetingFormat format;
  final String query;

  /// If non-null, only show meetings with this fellowship ('AA', 'NA', etc.).
  final String? fellowship;

  /// BCP-47 language code filter.
  /// • 'en' (default) — English meetings only
  /// • 'es'           — Spanish (Español) only
  /// • 'fr'           — French (Français) only
  /// • null           — all languages
  ///
  /// This is pre-set to 'en' in the default filter so new users see English
  /// meetings by default. Tap "All" in the Language section to show every
  /// language, or select a specific language to narrow further.
  final String? language;

  const MeetingFilter({
    this.weekday,
    this.timeOfDay,
    this.typeCodes = const {},
    this.format = MeetingFormat.all,
    this.query = '',
    this.fellowship,
    this.language = 'en',
  });

  /// Number of active (non-default) filter conditions — shown as a badge count.
  /// Language does NOT increment this counter when it's the default 'en';
  /// only when the user selects "All" or a non-English language does it count.
  int get activeCount {
    int n = 0;
    if (weekday != null) n++;
    if (timeOfDay != null) n++;
    if (format != MeetingFormat.all) n++;
    if (typeCodes.isNotEmpty) n++;
    if (fellowship != null) n++;
    if (language != 'en') n++; // null (all) or 'es'/'fr' counts as active
    return n;
  }

  MeetingFilter copyWith({
    Object? weekday = _sentinel,
    Object? timeOfDay = _sentinel,
    Set<String>? typeCodes,
    MeetingFormat? format,
    String? query,
    Object? fellowship = _sentinel,
    Object? language = _sentinel,
  }) =>
      MeetingFilter(
        weekday: weekday == _sentinel ? this.weekday : weekday as int?,
        timeOfDay: timeOfDay == _sentinel
            ? this.timeOfDay
            : timeOfDay as MeetingTimeOfDay?,
        typeCodes: typeCodes ?? this.typeCodes,
        format: format ?? this.format,
        query: query ?? this.query,
        fellowship:
            fellowship == _sentinel ? this.fellowship : fellowship as String?,
        language:
            language == _sentinel ? this.language : language as String?,
      );

  static const _sentinel = Object();

  List<Meeting> apply(List<Meeting> meetings) {
    return meetings.where((m) {
      if (fellowship != null &&
          m.fellowship.toUpperCase() != fellowship!.toUpperCase()) return false;
      if (weekday != null && m.weekday != weekday) return false;

      if (timeOfDay != null) {
        final parts = m.startTime.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final min = int.tryParse(parts[1]) ?? 0;
          final mins = h * 60 + min;
          if (!timeOfDay!.matchesMinutes(mins)) return false;
        }
      }

      if (format == MeetingFormat.inPerson && (m.isOnline && !m.isHybrid)) {
        return false;
      }
      if (format == MeetingFormat.online && !m.isOnline) return false;
      if (format == MeetingFormat.hybrid && !m.isHybrid) return false;
      if (typeCodes.isNotEmpty) {
        final parsed = parseMeetingTypeCodes(m.typeCodes);
        if (!typeCodes.any(parsed.contains)) return false;
      }
      if (language != null && m.language != language) return false;
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!m.name.toLowerCase().contains(q) &&
            !(m.city.toLowerCase().contains(q)) &&
            !(m.locationName?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

MeetingFilter _defaultFilter() => MeetingFilter(
      weekday: todayWeekday(),
      timeOfDay: currentMeetingTimeOfDay(),
      language: 'en',
    );

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final meetingFilterProvider =
    StateProvider<MeetingFilter>((ref) => _defaultFilter());

final allMeetingsProvider = StreamProvider<List<Meeting>>((ref) {
  return ref.watch(meetingsRepositoryProvider).watchAll();
});

final bookmarkedMeetingsProvider = StreamProvider<List<Meeting>>((ref) {
  return ref.watch(meetingsRepositoryProvider).watchBookmarked();
});

final attendanceLogsProvider = StreamProvider<List<AttendanceLog>>((ref) {
  return ref.watch(meetingsRepositoryProvider).watchAttendance();
});

final filteredMeetingsProvider = Provider<List<Meeting>>((ref) {
  final all = ref.watch(allMeetingsProvider).valueOrNull ?? [];
  final filter = ref.watch(meetingFilterProvider);
  return filter.apply(all);
});
