import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meeting_source_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Static JSON feed served by Code4Recovery on behalf of OIAA.
///
/// The hash `6436f5a3f03fdecef8459055` is OIAA's permanent MongoDB ObjectID
/// in the Code4Recovery OML infrastructure (created April 2023).  The file is
/// updated by OIAA admins and served statically; it does **not** change on
/// every request.
///
/// How this was discovered:
///   aa-intergroup.org/meetings/ loads the Code4Recovery "Online Meeting List"
///   (OML) component via oml.code4recovery.org/online-meeting-list.js.
///   That script fetches this JSON file to populate the meeting directory.
///   Confirmed via browser DevTools Network panel — returns 8 000+ meetings.
const _kOiaaFeedUrl =
    'https://data.aa-intergroup.org/6436f5a3f03fdecef8459055.json';

// ─────────────────────────────────────────────────────────────────────────────
// Adapter
// ─────────────────────────────────────────────────────────────────────────────

/// Pulls online-only AA meetings from the Online Intergroup of AA (OIAA).
///
/// Unlike the regional TSML adapters, this adapter has no geographic
/// restriction — all online meetings are accessible regardless of location.
///
/// Data source: Code4Recovery OML JSON feed at [_kOiaaFeedUrl].
///
/// Feed format (OML):
/// ```json
/// [
///   {
///     "slug":           "global-mens-meditation-5",
///     "name":           "Global Men's Meditation",
///     "group":          "Global Men's Meditation",
///     "location":       "Global Men's Meditation",
///     "day":            5,
///     "time":           "08:30",
///     "timezone":       "America/Los_Angeles",
///     "types":          ["EN", "C", "M", "MED"],
///     "conference_url": "https://zoom.us/j/...",
///     "regions":        [],
///     "updated":        "2024-01-24 18:35:10.251"
///   }, ...
/// ]
/// ```
///
/// Key differences from TSML REST format:
/// - Single static file, no pagination.
/// - `time` is already in 24-hour "HH:MM" format.
/// - `day` follows TSML convention: 0 = Sunday … 6 = Saturday.
/// - No physical coordinates (all meetings are online).
///
/// All meetings returned by this adapter have [MeetingDto.isOnline] == `true`.
class OiaaAdapter implements MeetingSourceAdapter {
  final http.Client _client;

  OiaaAdapter({http.Client? client}) : _client = client ?? http.Client();

  // ── MeetingSourceAdapter ─────────────────────────────────────────────────

  @override
  String get sourceId => 'oiaa-online';

  @override
  String get displayName => 'OIAA — Online Meetings';

  @override
  List<String> get fellowships => ['AA'];

  @override
  bool get enabledByDefault => true;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  @override
  Future<List<MeetingDto>> fetchAll() => _fetchFeed();

  @override
  // The OML feed is a static snapshot — no delta endpoint exists.
  // Always return the full set; the sync service deduplicates via externalId.
  Future<List<MeetingDto>> fetchUpdatedSince(DateTime since) => _fetchFeed();

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<List<MeetingDto>> _fetchFeed() async {
    final uri = Uri.parse(_kOiaaFeedUrl);
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception(
          'OIAA feed returned HTTP ${response.statusCode}. '
          'URL: $_kOiaaFeedUrl');
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      throw Exception(
          'OIAA feed: expected a JSON array, got ${body.runtimeType}.');
    }

    return (body as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_parseMeeting)
        .whereType<MeetingDto>()
        .toList();
  }

  // ── JSON → DTO ────────────────────────────────────────────────────────────

  MeetingDto? _parseMeeting(Map<String, dynamic> m) {
    try {
      // ── Type codes ───────────────────────────────────────────────────────
      final rawTypes = <String>[];
      final typesRaw = m['types'];
      if (typesRaw is List) {
        rawTypes.addAll(typesRaw.map((t) => t.toString().toUpperCase()));
      } else if (typesRaw is String && typesRaw.isNotEmpty) {
        rawTypes.addAll(typesRaw.split(',').map((s) => s.trim().toUpperCase()));
      }

      // Guarantee the online flag — every OIAA meeting is online-only.
      if (!rawTypes.contains('ONL')) rawTypes.add('ONL');

      final isHybrid = rawTypes.contains('H') || rawTypes.contains('HYBRID');

      // ── Conference URL / platform ─────────────────────────────────────────
      final confUrl = _str(m['conference_url']) ?? _str(m['url']);
      final confPhone = _str(m['conference_phone']) ??
          _str(m['phone']) ??
          _str(m['dial_in']);

      String? platform;
      if (confUrl != null) {
        if (confUrl.contains('zoom.us'))            platform = 'zoom';
        else if (confUrl.contains('teams.microsoft')) platform = 'teams';
        else if (confUrl.contains('meet.google'))    platform = 'google-meet';
        else if (confUrl.contains('jitsi'))          platform = 'jitsi';
        else if (confUrl.contains('gotomeeting'))    platform = 'gotomeeting';
      } else if (confPhone != null) {
        platform = 'phone';
      }

      // ── Time ─────────────────────────────────────────────────────────────
      // OML `time` is already in 24-hour "HH:MM" format — no conversion needed.
      final startTime = _str(m['time']) ?? '00:00';

      // ── Updated timestamp ─────────────────────────────────────────────────
      DateTime? lastUpdated;
      final updStr = _str(m['updated']);
      if (updStr != null) lastUpdated = DateTime.tryParse(updStr);

      // ── Unique ID ─────────────────────────────────────────────────────────
      // OML uses `slug` as the stable per-meeting identifier.
      final externalId = _str(m['slug'])
          ?? _str(m['id'] is int ? m['id'].toString() : m['id'])
          ?? '';

      // ── Name / location ───────────────────────────────────────────────────
      // OML often has identical `name`, `group`, and `location` values.
      // Use `name` as the meeting name and `location` as the venue label.
      final name         = _str(m['name']) ?? '(Unnamed Meeting)';
      final locationName = _str(m['location']) ?? _str(m['group']);

      return MeetingDto(
        externalId:     externalId,
        name:           name,
        fellowship:     'AA',
        locationName:   locationName,
        // Online meetings have no physical coordinates.
        latitude:       null,
        longitude:      null,
        address:        null,
        city:           'Online',
        state:          '',
        country:        'US',
        weekday:        _toInt(m['day']) ?? 0,
        startTime:      startTime,
        durationMinutes: null,
        typeCodes:      rawTypes,
        isOnline:       true,
        isHybrid:       isHybrid,
        conferenceUrl:  confUrl,
        conferencePhone: confPhone,
        onlinePlatform: platform,
        notes:          _str(m['notes']),
        lastUpdated:    lastUpdated,
      );
    } catch (_) {
      return null; // skip malformed rows silently
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
