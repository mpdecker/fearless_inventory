import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meeting_source_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// AA Meeting Guide API (aa-intergroup.org aggregator).
/// TSML-compatible JSON feed; no API key required for read operations.
const _kBaseUrl = 'https://api.aa-intergroup.org/api/v1/meetings';

/// Max results per page (the API caps at 1000).
const _kPageSize = 1000;

// ─────────────────────────────────────────────────────────────────────────────
// Adapter
// ─────────────────────────────────────────────────────────────────────────────

/// Pulls AA meetings from the AA International Meeting Guide API.
///
/// Each instance is scoped to a named [region] and carries a unique
/// [sourceId] so that multiple regional adapters can coexist in the sync
/// engine without colliding on DB keys.
///
/// ### Typical usage
/// ```dart
/// MeetingGuideAdapter.newEngland()
/// MeetingGuideAdapter.midAtlantic()
/// MeetingGuideAdapter(regionKey: 'midwest',  states: kUsRegions['midwest']!)
/// MeetingGuideAdapter(regionKey: 'national', states: kAllUsStates)
/// ```
class MeetingGuideAdapter implements MeetingSourceAdapter {
  final String regionKey;
  final List<String> states;
  final http.Client _client;

  /// Construct with explicit [regionKey] and [states].
  ///
  /// [regionKey] is appended to the stable source ID
  /// (`meeting-guide-aa-<regionKey>`), so every region has independent sync
  /// state and upsert dedup in the DB.
  MeetingGuideAdapter({
    required this.regionKey,
    required this.states,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ── Named region factories ────────────────────────────────────────────────

  factory MeetingGuideAdapter.newEngland({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'new_england',
        states: kUsRegions['new_england']!,
        client: client,
      );

  factory MeetingGuideAdapter.midAtlantic({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'mid_atlantic',
        states: kUsRegions['mid_atlantic']!,
        client: client,
      );

  factory MeetingGuideAdapter.southeast({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'southeast',
        states: kUsRegions['southeast']!,
        client: client,
      );

  factory MeetingGuideAdapter.midwest({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'midwest',
        states: kUsRegions['midwest']!,
        client: client,
      );

  factory MeetingGuideAdapter.south({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'south',
        states: kUsRegions['south']!,
        client: client,
      );

  factory MeetingGuideAdapter.mountain({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'mountain',
        states: kUsRegions['mountain']!,
        client: client,
      );

  factory MeetingGuideAdapter.pacificNorthwest({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'pacific_northwest',
        states: kUsRegions['pacific_northwest']!,
        client: client,
      );

  factory MeetingGuideAdapter.california({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'california',
        states: kUsRegions['california']!,
        client: client,
      );

  /// Fetches all US states in one adapter.  Use sparingly — large payload.
  factory MeetingGuideAdapter.national({http.Client? client}) =>
      MeetingGuideAdapter(
        regionKey: 'national',
        states: kAllUsStates,
        client: client,
      );

  // ── MeetingSourceAdapter ─────────────────────────────────────────────────

  @override
  String get sourceId => 'meeting-guide-aa-$regionKey';

  @override
  String get displayName {
    const labels = {
      'new_england': 'AA Meeting Guide — New England',
      'mid_atlantic': 'AA Meeting Guide — Mid-Atlantic',
      'southeast': 'AA Meeting Guide — Southeast',
      'midwest': 'AA Meeting Guide — Midwest',
      'south': 'AA Meeting Guide — South',
      'mountain': 'AA Meeting Guide — Mountain',
      'pacific_northwest': 'AA Meeting Guide — Pacific Northwest',
      'california': 'AA Meeting Guide — California',
      'national': 'AA Meeting Guide — National',
    };
    return labels[regionKey] ?? 'AA Meeting Guide — $regionKey';
  }

  @override
  List<String> get fellowships => ['AA'];

  @override
  bool get enabledByDefault => true;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  @override
  Future<List<MeetingDto>> fetchAll() => _fetchPaginated();

  @override
  Future<List<MeetingDto>> fetchUpdatedSince(DateTime since) async {
    try {
      return await _fetchPaginated(updatedSince: since);
    } catch (_) {
      return fetchAll();
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<List<MeetingDto>> _fetchPaginated({DateTime? updatedSince}) async {
    final results = <MeetingDto>[];
    int offset = 0;

    while (true) {
      final batch = await _fetchPage(offset: offset, updatedSince: updatedSince);
      results.addAll(batch);
      if (batch.length < _kPageSize) break;
      offset += _kPageSize;
    }

    return results;
  }

  Future<List<MeetingDto>> _fetchPage({
    required int offset,
    DateTime? updatedSince,
  }) async {
    // Build query: repeated state[] params are handled via URI encoding.
    final queryParts = <String>[];
    for (final s in states) {
      queryParts.add('state[]=${Uri.encodeComponent(s)}');
    }
    queryParts.add('limit=$_kPageSize');
    queryParts.add('offset=$offset');
    if (updatedSince != null) {
      queryParts.add(
          'updated_since=${Uri.encodeComponent(updatedSince.toUtc().toIso8601String())}');
    }

    final uri = Uri.parse('$_kBaseUrl?${queryParts.join('&')}');

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception(
          'Meeting Guide API ${response.statusCode} for $regionKey: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final List<dynamic> rawList = body is Map ? (body['data'] ?? []) : body;

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(_parseMeeting)
        .whereType<MeetingDto>()
        .toList();
  }

  // ── JSON → DTO ────────────────────────────────────────────────────────────

  MeetingDto? _parseMeeting(Map<String, dynamic> m) {
    try {
      final rawTypes = (m['types'] as List<dynamic>? ?? [])
          .map((t) => t.toString().toUpperCase())
          .toList();

      final isOnline = rawTypes.contains('ONL') || rawTypes.contains('TC');
      final isHybrid = rawTypes.contains('H') ||
          (rawTypes.contains('ONL') &&
              (m['latitude'] != null || m['formatted_address'] != null));

      final confUrl = _str(m['conference_url']);
      final confPhone = _str(m['conference_phone']);

      String? platform;
      if (confUrl != null) {
        if (confUrl.contains('zoom.us')) platform = 'zoom';
        else if (confUrl.contains('teams.microsoft')) platform = 'teams';
        else if (confUrl.contains('meet.google')) platform = 'google-meet';
      } else if (confPhone != null) {
        platform = 'phone';
      }

      int? durationMins;
      final startStr = _str(m['time']) ?? '00:00';
      final endStr = _str(m['end_time']);
      if (endStr != null) {
        final start = _parseTime(startStr);
        final end = _parseTime(endStr);
        if (start != null && end != null) {
          durationMins = end.inMinutes - start.inMinutes;
          if (durationMins <= 0) durationMins = null;
        }
      }

      DateTime? updated;
      final updStr = _str(m['updated']);
      if (updStr != null) updated = DateTime.tryParse(updStr);

      final city = _str(m['city']) ?? '';
      final state = _str(m['state']) ??
          _str(m['province']) ??
          _inferState(m) ??
          '';

      return MeetingDto(
        externalId: _str(m['id'] is int
                ? m['id'].toString()
                : m['id']) ??
            _str(m['slug']) ??
            '',
        name: _str(m['name']) ?? '(Unnamed Meeting)',
        fellowship: 'AA',
        locationName: _str(m['location']),
        latitude: _toDouble(m['latitude']),
        longitude: _toDouble(m['longitude']),
        address: _str(m['formatted_address']) ?? _buildAddress(m),
        city: city,
        state: state.toUpperCase(),
        country: (_str(m['country']) ?? 'us').toUpperCase(),
        weekday: (m['day'] as int? ?? 0),
        startTime: startStr,
        durationMinutes: durationMins,
        typeCodes: rawTypes,
        isOnline: isOnline,
        isHybrid: isHybrid,
        conferenceUrl: confUrl,
        conferencePhone: confPhone,
        onlinePlatform: platform,
        notes: _str(m['notes']),
        lastUpdated: updated,
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

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static Duration? _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final min = int.tryParse(parts[1]);
    if (h == null || min == null) return null;
    return Duration(hours: h, minutes: min);
  }

  static String? _inferState(Map<String, dynamic> m) {
    final addr = _str(m['formatted_address']) ?? '';
    final match = RegExp(r'\b([A-Z]{2})\b').firstMatch(addr);
    return match?.group(1);
  }

  static String? _buildAddress(Map<String, dynamic> m) {
    final parts = [
      _str(m['address']),
      _str(m['city']),
      _str(m['state']),
      _str(m['postal_code']),
    ].whereType<String>();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}
