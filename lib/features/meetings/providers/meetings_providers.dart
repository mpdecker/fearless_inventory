import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/meetings_repository.dart';
import '../services/location_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────

enum MeetingFormat { all, inPerson, online, hybrid }

/// Sub-mode for Browse and Search: physical meetings (in-person + hybrid) vs
/// online-only meetings, each with its own list semantics.
enum MeetingFinderMode {
  /// In-person and hybrid meetings; location + distance apply when available.
  nearby,
  /// Online-only meetings worldwide; location and distance do not apply.
  onlineOnly,
}

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

/// Minutes until [m] next starts, relative to the device's local wall-clock
/// time right now.
///
/// Algorithm:
///   1. Convert `m.startTime` ("HH:mm") to minutes-from-midnight.
///   2. Compute how many days ahead the meeting's weekday is.
///   3. If the meeting is today but has already started (or is starting this
///      very minute), treat it as 7 days away (same slot next week).
///   4. Return `daysAhead × 1440 + meetingMins − nowMins`.
///
/// The result is always ≥ 0 (or 1 for a meeting starting right now).
/// Sorting ascending by this value puts the soonest meetings first.
int minutesUntilNextOccurrence(Meeting m) {
  final now     = DateTime.now();                   // device local time
  final nowMins = now.hour * 60 + now.minute;       // minutes since midnight
  final nowDay  = now.weekday % 7;                  // TSML 0=Sun…6=Sat

  final parts      = m.startTime.split(':');
  final meetingMins = (int.tryParse(parts[0]) ?? 0) * 60
                    + (int.tryParse(parts[1]) ?? 0);

  // Days until this meeting's weekday (0 = today, 1 = tomorrow, … 6).
  int daysAhead = (m.weekday - nowDay + 7) % 7;

  // If the slot is today but has already passed, push to next week.
  if (daysAhead == 0 && meetingMins <= nowMins) {
    daysAhead = 7;
  }

  return daysAhead * 24 * 60 + meetingMins - nowMins;
}

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
          m.fellowship.toUpperCase() != fellowship!.toUpperCase()) {
        return false;
      }
      if (weekday != null && m.weekday != weekday) {
        return false;
      }

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

MeetingFilter _defaultFilter() => const MeetingFilter(language: 'en');

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final meetingFilterProvider =
    StateProvider<MeetingFilter>((ref) => _defaultFilter());

/// Shared between Browse and Search tabs (same finder mode in both).
final meetingFinderModeProvider =
    StateProvider<MeetingFinderMode>((ref) => MeetingFinderMode.nearby);

final allMeetingsProvider = StreamProvider<List<Meeting>>((ref) {
  return ref.watch(meetingsRepositoryProvider).watchAll();
});

final bookmarkedMeetingsProvider = StreamProvider<List<Meeting>>((ref) {
  return ref
      .watch(meetingsRepositoryProvider)
      .watchBookmarked()
      .map((list) {
        final mins = _computeMinutes(list);
        return list..sort((a, b) => mins[a.id]!.compareTo(mins[b.id]!));
      });
});

final attendanceLogsProvider = StreamProvider<List<AttendanceLog>>((ref) {
  return ref.watch(meetingsRepositoryProvider).watchAttendance();
});

/// Minutes-until-next-occurrence for every meeting in [meetings].
/// Calls [DateTime.now()] exactly once regardless of list size.
Map<int, int> _computeMinutes(List<Meeting> meetings) {
  final now = DateTime.now();
  final nowMins = now.hour * 60 + now.minute;
  final nowDay = now.weekday % 7;
  final result = <int, int>{};
  for (final m in meetings) {
    final parts = m.startTime.split(':');
    final mMins = (int.tryParse(parts[0]) ?? 0) * 60
                + (int.tryParse(parts[1]) ?? 0);
    int daysAhead = (m.weekday - nowDay + 7) % 7;
    if (daysAhead == 0 && mMins <= nowMins) daysAhead = 7;
    result[m.id] = daysAhead * 24 * 60 + mMins - nowMins;
  }
  return result;
}

/// Pre-computed minutes until next occurrence, keyed by meeting id.
/// Recomputes only when the full meetings list changes (e.g. after a sync).
final meetingMinutesProvider = Provider<Map<int, int>>((ref) {
  final all = ref.watch(allMeetingsProvider).valueOrNull ?? [];
  return _computeMinutes(all);
});

/// Pre-computed haversine distances (km) from the active location,
/// keyed by meeting id. Recomputes only when location or meetings change.
final meetingDistancesProvider = Provider<Map<int, double>>((ref) {
  final all = ref.watch(allMeetingsProvider).valueOrNull ?? [];
  final loc = ref.watch(activeLocationProvider).valueOrNull;
  if (loc == null) return const {};
  final result = <int, double>{};
  for (final m in all) {
    if (m.latitude != null && m.longitude != null) {
      result[m.id] = haversineKm(
        loc.latitude, loc.longitude, m.latitude!, m.longitude!,
      );
    }
  }
  return result;
});

final filteredMeetingsProvider = Provider<List<Meeting>>((ref) {
  final all = ref.watch(allMeetingsProvider).valueOrNull ?? [];
  final filter = ref.watch(meetingFilterProvider);
  final mode = ref.watch(meetingFinderModeProvider);
  final mins = ref.watch(meetingMinutesProvider);
  int cmp(Meeting a, Meeting b) =>
      (mins[a.id] ?? 0).compareTo(mins[b.id] ?? 0);

  if (mode == MeetingFinderMode.onlineOnly) {
    final pool =
        all.where((m) => m.isOnline && !m.isHybrid).toList(growable: false);
    final list = filter.copyWith(format: MeetingFormat.all).apply(pool);
    list.sort(cmp);
    return list;
  }

  final pool =
      all.where((m) => !(m.isOnline && !m.isHybrid)).toList(growable: false);
  final list = filter.apply(pool);
  list.sort(cmp);
  return list;
});

/// Result type for [browseMeetingsProvider].
class BrowseResult {
  final List<Meeting> display;
  /// Distances (km) for in-person meetings visible in the list.
  final Map<int, double> distancesKm;
  const BrowseResult(this.display, this.distancesKm);
}

/// Location-aware meeting list for the Browse and (optionally) Search tabs.
///
/// [MeetingFinderMode.nearby]: in-person and hybrid only; when a location is
/// set, rows are restricted to [distanceRadiusMiProvider] (default 100 mi).
/// Pure online meetings never appear here (use the Online subtab).
///
/// [MeetingFinderMode.onlineOnly]: online-only meetings worldwide; format
/// filter is ignored (treated as "all") for this list.
final browseMeetingsProvider = Provider<BrowseResult>((ref) {
  final mode = ref.watch(meetingFinderModeProvider);
  if (mode == MeetingFinderMode.onlineOnly) {
    return _browseOnlineOnlyMeetings(ref);
  }
  return _browseNearbyMeetings(ref);
});

BrowseResult _browseNearbyMeetings(Ref ref) {
  final all = ref.watch(allMeetingsProvider).valueOrNull ?? [];
  final filter = ref.watch(meetingFilterProvider);
  final loc = ref.watch(activeLocationProvider).valueOrNull;
  final radius = ref.watch(distanceRadiusMiProvider);
  final mins = ref.watch(meetingMinutesProvider);
  final distances = ref.watch(meetingDistancesProvider);

  final pool =
      all.where((m) => !(m.isOnline && !m.isHybrid)).toList(growable: false);
  final filtered = filter.apply(pool);
  int cmp(Meeting a, Meeting b) =>
      (mins[a.id] ?? 0).compareTo(mins[b.id] ?? 0);

  if (loc != null) {
    final radiusKm = miToKm(radius ?? 100.0);
    final visibleDistances = <int, double>{};
    final nearby = <Meeting>[];

    for (final m in filtered) {
      if (m.isOnline && !m.isHybrid) continue;
      final km = distances[m.id];
      if (km == null || km > radiusKm) continue;
      nearby.add(m);
      visibleDistances[m.id] = km;
    }
    nearby.sort(cmp);
    return BrowseResult(nearby, visibleDistances);
  }

  return BrowseResult(filtered..sort(cmp), const {});
}

BrowseResult _browseOnlineOnlyMeetings(Ref ref) {
  final all = ref.watch(allMeetingsProvider).valueOrNull ?? [];
  final filter = ref.watch(meetingFilterProvider);
  final mins = ref.watch(meetingMinutesProvider);
  int cmp(Meeting a, Meeting b) =>
      (mins[a.id] ?? 0).compareTo(mins[b.id] ?? 0);

  final pool =
      all.where((m) => m.isOnline && !m.isHybrid).toList(growable: false);
  final list = filter.copyWith(format: MeetingFormat.all).apply(pool);
  list.sort(cmp);
  return BrowseResult(list, const {});
}
