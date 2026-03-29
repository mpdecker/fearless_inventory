import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meeting_source_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// NA Meeting Guide API base URL.
///
/// Narcotics Anonymous World Services (NAWS) has not published a stable,
/// versioned JSON API for third-party use.  The endpoint below was used by
/// partner apps as recently as 2024 but returns HTTP 404 as of March 2026.
///
/// ⚠️  Until NAWS publishes an updated endpoint, the recommended path for
///     regional NA meeting data is to pull from the individual NA regional
///     website's TSML WordPress feed (see [TsmlAdapter]):
///
///       GET https://<na-region-site>/wp-json/tsml/meetings
///
///     Each NERNA sub-region that runs the "12 Step Meeting List" WordPress
///     plugin exposes meetings at that path.  The [NaMeetingGuideAdapter]
///     is kept here for when NAWS publishes a replacement endpoint; pass
///     the new URL via [customBaseUrl] without modifying this file.
///
/// Reference: https://www.na.org/meetingsearch/
const _kNaBaseUrl = 'https://www.na.org/meetingsearch/searchresults.php';

const _kPageSize = 500;

// ─────────────────────────────────────────────────────────────────────────────
// Adapter
// ─────────────────────────────────────────────────────────────────────────────

/// Pulls NA meetings from NAWS and/or regional NA websites.
///
/// ### Status: Beta scaffolding
/// This adapter follows the same interface as [MeetingGuideAdapter] and is
/// ready to be enabled once a reliable NA API endpoint is confirmed for the
/// target region.  The constructor accepts a [customBaseUrl] for plugging in
/// a region's specific URL without touching this class.
///
/// ### Enabling
/// Uncomment the `NaMeetingGuideAdapter` line(s) in `meeting_sync_service.dart`
/// after verifying API access for the target region.
class NaMeetingGuideAdapter implements MeetingSourceAdapter {
  final String regionKey;
  final List<String> states;

  /// Override the default NAWS endpoint with a regional URL.
  /// Example: `https://nalosangeles.org/wp-json/aaintergroup/v1/meetings`
  final String? customBaseUrl;

  final http.Client _client;

  NaMeetingGuideAdapter({
    required this.regionKey,
    required this.states,
    this.customBaseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // ── Named region factories ────────────────────────────────────────────────

  factory NaMeetingGuideAdapter.newEngland({
    String? customBaseUrl,
    http.Client? client,
  }) =>
      NaMeetingGuideAdapter(
        regionKey: 'new_england',
        states: kUsRegions['new_england']!,
        customBaseUrl: customBaseUrl,
        client: client,
      );

  factory NaMeetingGuideAdapter.midAtlantic({
    String? customBaseUrl,
    http.Client? client,
  }) =>
      NaMeetingGuideAdapter(
        regionKey: 'mid_atlantic',
        states: kUsRegions['mid_atlantic']!,
        customBaseUrl: customBaseUrl,
        client: client,
      );

  factory NaMeetingGuideAdapter.national({
    String? customBaseUrl,
    http.Client? client,
  }) =>
      NaMeetingGuideAdapter(
        regionKey: 'national',
        states: kAllUsStates,
        customBaseUrl: customBaseUrl,
        client: client,
      );

  // ── NA regional factories (territory-specific) ────────────────────────────

  /// **NERNA** — New England Region of Narcotics Anonymous.
  ///
  /// Covers Massachusetts (all areas) and Rhode Island (Greater Providence).
  /// Primary website: https://nerna.org
  ///
  /// Preferred feed path (when NERNA opens their TSML feed):
  ///   TsmlAdapter(id: 'tsml-na-nerna', baseUrl: 'https://nerna.org', fellowship: 'NA')
  ///
  /// This constructor uses the NAWS state-filtered endpoint as a fallback;
  /// supply [customBaseUrl] to point at a verified NERNA-specific feed.
  factory NaMeetingGuideAdapter.nerna({
    String? customBaseUrl,
    http.Client? client,
  }) =>
      NaMeetingGuideAdapter(
        regionKey: 'nerna',
        states: kUsRegions['nerna']!,
        customBaseUrl: customBaseUrl,
        client: client,
      );

  /// **NNERNA** — Northern New England Region of Narcotics Anonymous.
  ///
  /// Covers New Hampshire, Maine, and Vermont.
  /// Primary website: https://nnerna.org
  ///
  /// Note: nnerna.org does not expose a TSML feed (verified Mar 2026).
  /// Supply [customBaseUrl] if a regional feed becomes available.
  factory NaMeetingGuideAdapter.nnerna({
    String? customBaseUrl,
    http.Client? client,
  }) =>
      NaMeetingGuideAdapter(
        regionKey: 'nnerna',
        states: kUsRegions['nnerna']!,
        customBaseUrl: customBaseUrl,
        client: client,
      );

  // ── MeetingSourceAdapter ─────────────────────────────────────────────────

  @override
  String get sourceId => 'meeting-guide-na-$regionKey';

  @override
  String get displayName {
    const labels = {
      'new_england': 'NA — New England',
      'mid_atlantic': 'NA — Mid-Atlantic',
      'southeast': 'NA — Southeast',
      'midwest': 'NA — Midwest',
      'south': 'NA — South',
      'mountain': 'NA — Mountain',
      'pacific_northwest': 'NA — Pacific Northwest',
      'california': 'NA — California',
      'national': 'NA — National',
      // NA regional bodies
      'nerna':  'NA — New England (NERNA)',
      'nnerna': 'NA — Northern New England (NNERNA)',
    };
    return labels[regionKey] ?? 'NA — $regionKey';
  }

  @override
  List<String> get fellowships => ['NA'];

  /// NA adapters are disabled by default until a regional API URL is confirmed.
  @override
  bool get enabledByDefault => false;

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

  String get _baseUrl => customBaseUrl ?? _kNaBaseUrl;

  Future<List<MeetingDto>> _fetchPaginated({DateTime? updatedSince}) async {
    final results = <MeetingDto>[];
    int offset = 0;

    while (true) {
      final batch =
          await _fetchPage(offset: offset, updatedSince: updatedSince);
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

    final uri = Uri.parse('$_baseUrl?${queryParts.join('&')}');

    final response = await _client
        .get(uri, headers: {
          'Accept': 'application/json',
          'User-Agent': 'FearlessInventory/1.0 (NA Meeting Locator)',
        })
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception(
          'NA Meeting API ${response.statusCode} for $regionKey: ${response.body}');
    }

    final body = jsonDecode(response.body);

    // Support both TSML wrapped `{"data":[...]}` and bare `[...]` formats.
    final List<dynamic> rawList = body is Map ? (body['data'] ?? body['meetings'] ?? []) : body;

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(_parseMeeting)
        .whereType<MeetingDto>()
        .toList();
  }

  // ── JSON → DTO ────────────────────────────────────────────────────────────

  /// NA TSML format is very similar to AA Meeting Guide format; the main
  /// differences are fellowship tag and some NA-specific type codes.
  MeetingDto? _parseMeeting(Map<String, dynamic> m) {
    try {
      final rawTypes = (m['types'] as List<dynamic>? ?? [])
          .map((t) => t.toString().toUpperCase())
          .toList();

      // Normalise some NA-specific abbreviations that differ from AA codes.
      final normTypes = rawTypes.map(_normaliseNaCode).toList();

      final isOnline = normTypes.contains('ONL') || normTypes.contains('TC');
      final isHybrid = normTypes.contains('H') ||
          (isOnline &&
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

      final startStr = _str(m['time']) ?? '00:00';
      final endStr = _str(m['end_time']);
      int? durationMins;
      if (endStr != null) {
        final s = _parseTime(startStr);
        final e = _parseTime(endStr);
        if (s != null && e != null) {
          durationMins = e.inMinutes - s.inMinutes;
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
        name: _str(m['name']) ?? '(Unnamed NA Meeting)',
        fellowship: 'NA',
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
        typeCodes: normTypes,
        isOnline: isOnline,
        isHybrid: isHybrid,
        conferenceUrl: confUrl,
        conferencePhone: confPhone,
        onlinePlatform: platform,
        notes: _str(m['notes']),
        lastUpdated: updated,
      );
    } catch (_) {
      return null;
    }
  }

  /// Map NA-specific type codes to the normalised codes in [kNaTypeCodes].
  /// Handles the common divergences seen in NA regional data.
  static String _normaliseNaCode(String code) {
    // Some NA feeds use lower-case or alternate abbreviations.
    const map = {
      'ONLINE': 'ONL',
      'HYBRID': 'H',
      'TEMP': 'TC',
      'STEP': 'St',
      'TRAD': 'Tr',
      'BEGINNER': 'BT',
      'OPEN': 'O',
      'CLOSED': 'C',
    };
    return map[code.toUpperCase()] ?? code;
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
