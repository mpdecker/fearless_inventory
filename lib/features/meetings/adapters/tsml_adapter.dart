import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meeting_source_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TsmlAdapter
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches AA (or NA/other) meeting data from any site running the
/// Code for Recovery "12 Step Meeting List" WordPress plugin (TSML).
///
/// These sites expose meetings at the WordPress REST path:
///   GET <baseUrl>/wp-json/tsml/meetings
///
/// Note: the WordPress REST namespace for this plugin is `tsml` — NOT
/// `twelvesteplist/v2` as some older documentation suggests.  All versions
/// of the plugin (including the latest 3.x series) register their routes
/// under the `tsml` namespace.
///
/// The response is a JSON array of meeting objects following the TSML
/// specification — the same standard used by 400+ AA intergroup and
/// service-entity websites worldwide and by the official Meeting Guide app.
///
/// ### Usage
/// ```dart
/// TsmlAdapter(
///   id:   'tsml-aa-nyc',
///   name: 'AA — Greater New York',
///   baseUrl: 'https://www.nyintergroup.org',
/// )
/// ```
///
/// If the site exposes the feed at a non-standard path (e.g. a static
/// `meetings.json` export), pass the full URL via [feedUrl] instead of
/// [baseUrl]; the adapter will use that URL directly and skip the path
/// construction.
class TsmlAdapter implements MeetingSourceAdapter {
  final String _id;
  final String _name;
  final String _feedUrl;
  final String _fellowship;
  final http.Client _client;

  /// Construct with a [baseUrl] that hosts the WP TSML plugin.
  /// The adapter appends `/wp-json/tsml/meetings` automatically.
  TsmlAdapter({
    required String id,
    required String name,
    required String baseUrl,
    String fellowship = 'AA',
    http.Client? client,
  })  : _id = id,
        _name = name,
        _fellowship = fellowship,
        _feedUrl = '${baseUrl.trimRight()}/wp-json/tsml/meetings',
        _client = client ?? http.Client();

  /// Construct with an explicit [feedUrl] when the feed is at a custom path
  /// (e.g. a static JSON file or a non-standard REST route).
  TsmlAdapter.withFeedUrl({
    required String id,
    required String name,
    required String feedUrl,
    String fellowship = 'AA',
    http.Client? client,
  })  : _id = id,
        _name = name,
        _fellowship = fellowship,
        _feedUrl = feedUrl,
        _client = client ?? http.Client();

  // ── MeetingSourceAdapter ─────────────────────────────────────────────────

  @override
  String get sourceId => _id;

  @override
  String get displayName => _name;

  @override
  List<String> get fellowships => [_fellowship];

  @override
  bool get enabledByDefault => true;

  // ── Fetch ─────────────────────────────────────────────────────────────────

  @override
  Future<List<MeetingDto>> fetchAll() async {
    return _fetchFeed();
  }

  @override
  Future<List<MeetingDto>> fetchUpdatedSince(DateTime since) async {
    // Some TSML installations support an `updated` query param for delta syncs.
    // Try a filtered fetch first; fall back to full fetch on failure.
    try {
      final filtered = await _fetchFeed(updatedSince: since);
      // If the server ignored the param it returns the full set — that's fine.
      return filtered;
    } catch (_) {
      return _fetchFeed();
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<List<MeetingDto>> _fetchFeed({DateTime? updatedSince}) async {
    String url = _feedUrl;
    if (updatedSince != null) {
      final iso = Uri.encodeComponent(updatedSince.toUtc().toIso8601String());
      url = '$url?updated=$iso';
    }

    final uri = Uri.parse(url);
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception(
          'TSML API ${response.statusCode} for $_name: ${response.body.substring(0, response.body.length.clamp(0, 200))}');
    }

    final body = jsonDecode(response.body);

    // The TSML v2 REST API returns either a bare array or { data: [...] }.
    final List<dynamic> rawList;
    if (body is List) {
      rawList = body;
    } else if (body is Map && body['data'] is List) {
      rawList = body['data'] as List;
    } else {
      rawList = [];
    }

    return rawList
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
        for (final t in typesRaw) {
          rawTypes.add(t.toString().toUpperCase());
        }
      } else if (typesRaw is String && typesRaw.isNotEmpty) {
        // Some TSML exports join types as a comma-separated string.
        rawTypes.addAll(
          typesRaw.split(',').map((s) => s.trim().toUpperCase()),
        );
      }

      final isOnline = rawTypes.contains('ONL') ||
          rawTypes.contains('TC') ||
          rawTypes.contains('ONLINE');
      final isHybrid = rawTypes.contains('H') || rawTypes.contains('HYBRID');

      // ── Online meeting info ───────────────────────────────────────────────
      final confUrl = _str(m['conference_url']) ?? _str(m['url']);
      final confPhone = _str(m['conference_phone']) ??
          _str(m['phone']) ??
          _str(m['dial_in']);

      String? platform;
      if (confUrl != null) {
        if (confUrl.contains('zoom.us')) platform = 'zoom';
        else if (confUrl.contains('teams.microsoft')) platform = 'teams';
        else if (confUrl.contains('meet.google')) platform = 'google-meet';
        else if (confUrl.contains('jitsi')) platform = 'jitsi';
        else if (confUrl.contains('gotomeeting')) platform = 'gotomeeting';
      } else if (confPhone != null) {
        platform = 'phone';
      }

      // ── Time ─────────────────────────────────────────────────────────────
      final startStr = _str(m['time']) ?? _str(m['start_time']) ?? '00:00';
      final endStr = _str(m['end_time']) ?? _str(m['end']);
      int? durationMins;
      if (endStr != null) {
        final s = _parseTime(startStr);
        final e = _parseTime(endStr);
        if (s != null && e != null) {
          durationMins = e.inMinutes - s.inMinutes;
          if (durationMins <= 0) durationMins = null;
        }
      }

      // ── Updated timestamp ─────────────────────────────────────────────────
      DateTime? updated;
      final updStr = _str(m['updated']);
      if (updStr != null) updated = DateTime.tryParse(updStr);

      // ── Location ─────────────────────────────────────────────────────────
      // TSML v2: address may be split into components or provided as
      // formatted_address. Build the best string we can.
      final city = _str(m['city']) ?? (isOnline ? 'Online' : '');
      final state = _str(m['state']) ?? _str(m['province']) ?? '';
      final formattedAddress = _str(m['formatted_address'])
          ?? _buildAddress(m);

      // ── Unique ID ────────────────────────────────────────────────────────
      final id = _str(m['id'] is int ? m['id'].toString() : m['id'])
          ?? _str(m['slug'])
          ?? _str(m['guid'])
          ?? '';

      // ── Language ──────────────────────────────────────────────────────────
      // Priority: explicit `lang`/`language` field → type-code heuristics → 'en'
      final langField = _str(m['lang']) ?? _str(m['language']);
      final language = _inferLanguage(langField, rawTypes);

      return MeetingDto(
        externalId: id,
        name: _str(m['name']) ?? _str(m['post_title']) ?? '(Unnamed Meeting)',
        fellowship: _fellowship,
        locationName: _str(m['location']) ?? _str(m['location_name']),
        latitude: _toDouble(m['latitude']),
        longitude: _toDouble(m['longitude']),
        address: formattedAddress,
        city: city,
        state: state.toUpperCase(),
        country: (_str(m['country']) ?? 'US').toUpperCase(),
        weekday: _toInt(m['day']) ?? 0,
        startTime: startStr,
        durationMinutes: durationMins,
        typeCodes: rawTypes,
        isOnline: isOnline,
        isHybrid: isHybrid,
        conferenceUrl: confUrl,
        conferencePhone: confPhone,
        onlinePlatform: platform,
        notes: _str(m['notes']) ?? _str(m['directions']),
        lastUpdated: updated,
        language: language,
      );
    } catch (_) {
      return null; // skip malformed rows silently
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Determine the meeting language from the explicit TSML field (if present)
  /// or from well-known type-code conventions.
  ///
  /// Type-code heuristics (common across TSML intergroup installations):
  ///   'FR'  → French (Français) — safe to infer; used by many QC/CA groups
  ///   'ES'  → Spanish (Español) — used by some southern US / Latino groups
  ///
  /// 'S' alone is intentionally excluded: it means "Speaker" in some regions
  /// and "Spanish" in others — too ambiguous to infer safely.
  static String _inferLanguage(String? langField, List<String> types) {
    if (langField != null) {
      final l = langField.toLowerCase();
      if (l.startsWith('fr')) return 'fr';
      if (l.startsWith('es') || l == 'spanish') return 'es';
      if (l.startsWith('en') || l == 'english') return 'en';
      // Pass through other BCP-47 codes as lowercase (e.g. 'pt', 'de', 'zh').
      return l.split('-').first; // strip region subtag (e.g. 'en-US' → 'en')
    }
    if (types.contains('FR')) return 'fr';
    if (types.contains('ES')) return 'es';
    return 'en';
  }

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

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static Duration? _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final min = int.tryParse(parts[1]);
    if (h == null || min == null) return null;
    return Duration(hours: h, minutes: min);
  }

  static String? _buildAddress(Map<String, dynamic> m) {
    final parts = [
      _str(m['address']),
      _str(m['city']),
      _str(m['state']),
      _str(m['postal_code']) ?? _str(m['zip']),
    ].whereType<String>().toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}
