import 'dart:convert';
import 'package:http/http.dart' as http;
import 'meeting_source_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TsmlPageAdapter
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches AA meeting data from sites running an older version of the
/// "12 Step Meeting List" (TSML) WordPress plugin that does **not** expose a
/// public REST API feed.
///
/// Older TSML installations (and those with the REST feed set to "Restricted")
/// embed all meeting data directly in the meetings HTML page as a JavaScript
/// variable:
///
/// ```js
/// var locations = {
///   "12345": {
///     "name": "First Church",
///     "latitude": 42.35,
///     "longitude": -71.06,
///     "formatted_address": "123 Main St, Boston, MA 02101, USA",
///     "url": "https://site.org/locations/first-church",
///     "meetings": [
///       { "day": 1, "time": "7:00 am", "name": "Monday Morning",
///         "url": "https://site.org/meetings/monday-morning",
///         "types": ["O", "D"] }
///     ]
///   }, ...
/// };
/// ```
///
/// This adapter fetches the HTML page, extracts that variable, and converts it
/// into [MeetingDto] objects.
///
/// ### Usage
/// ```dart
/// TsmlPageAdapter(
///   id:           'tsml-page-ema-boston',
///   name:         'AA — Eastern Massachusetts (Boston)',
///   meetingsUrl:  'https://aaboston.org/meetings',
/// )
/// ```
///
/// The [meetingsUrl] is the full URL of the WordPress page that contains the
/// TSML meeting-finder shortcode (typically `<site>/meetings`).
class TsmlPageAdapter implements MeetingSourceAdapter {
  final String _id;
  final String _name;
  final String _meetingsUrl;
  final String _fellowship;
  final http.Client _client;

  TsmlPageAdapter({
    required String id,
    required String name,
    required String meetingsUrl,
    String fellowship = 'AA',
    http.Client? client,
  })  : _id = id,
        _name = name,
        _meetingsUrl = meetingsUrl,
        _fellowship = fellowship,
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
  Future<List<MeetingDto>> fetchAll() => _fetchAndParse();

  @override
  // No delta endpoint — always return the full set.
  Future<List<MeetingDto>> fetchUpdatedSince(DateTime since) => _fetchAndParse();

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<List<MeetingDto>> _fetchAndParse() async {
    final uri = Uri.parse(_meetingsUrl);
    final response = await _client
        .get(uri, headers: {
          'Accept': 'text/html,application/xhtml+xml',
          'User-Agent': 'FearlessInventory/1.0 (meeting-sync)',
        })
        .timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception(
          'HTTP ${response.statusCode} fetching meetings page for $_name');
    }

    return _parseLocationsFromHtml(response.body);
  }

  List<MeetingDto> _parseLocationsFromHtml(String html) {
    // ── Find `var locations = {` ─────────────────────────────────────────
    // The TSML plugin injects a <script> block containing:
    //   var locations = { "<id>": { ... }, ... };
    const marker = 'var locations = ';
    final markerIdx = html.indexOf(marker);
    if (markerIdx == -1) {
      throw Exception(
          '$_name: could not find "var locations" in HTML page. '
          'The site may have updated its TSML version — try a TsmlAdapter instead.');
    }

    // ── Extract the full JSON object via bracket matching ────────────────
    final jsonStart = markerIdx + marker.length;
    if (jsonStart >= html.length || html[jsonStart] != '{') {
      throw Exception('$_name: "var locations" value is not a JSON object.');
    }

    int depth = 0;
    int jsonEnd = -1;
    for (int i = jsonStart; i < html.length; i++) {
      final ch = html[i];
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) {
          jsonEnd = i + 1;
          break;
        }
      }
    }
    if (jsonEnd == -1) {
      throw Exception('$_name: could not find closing brace for "var locations".');
    }

    // ── Decode JSON ──────────────────────────────────────────────────────
    final Map<String, dynamic> locationsMap;
    try {
      locationsMap =
          (jsonDecode(html.substring(jsonStart, jsonEnd)) as Map).cast();
    } catch (e) {
      throw Exception('$_name: failed to parse "var locations" JSON: $e');
    }

    // ── Convert to MeetingDto list ───────────────────────────────────────
    final results = <MeetingDto>[];

    for (final entry in locationsMap.entries) {
      final loc = entry.value as Map<String, dynamic>? ?? {};

      final locName   = _str(loc['name']) ?? '';
      final lat       = _toDouble(loc['latitude']);
      final lng       = _toDouble(loc['longitude']);
      final address   = _str(loc['formatted_address']) ?? '';
      final (city, state) = _parseCityState(address);

      final rawMeetings = loc['meetings'] as List<dynamic>? ?? [];

      for (final rawM in rawMeetings.whereType<Map<String, dynamic>>()) {
        // ── Type codes ──────────────────────────────────────────────────
        final typesRaw = rawM['types'];
        final types = <String>[];
        if (typesRaw is List) {
          types.addAll(typesRaw.map((t) => t.toString().toUpperCase()));
        }

        final isOnline = types.contains('ONL') || types.contains('TC');
        final isHybrid = types.contains('H') || types.contains('HYBRID');

        // ── Unique ID — extract slug from meeting URL ──────────────────
        final meetingUrl = _str(rawM['url']) ?? '';
        final slug = Uri.parse(meetingUrl).pathSegments
            .where((s) => s.isNotEmpty)
            .lastOrNull ?? '';
        final id = slug.isNotEmpty ? slug : '${entry.key}-${rawM['name']}';

        // ── Time — convert 12-hour "6:00 am" to 24-hour "06:00" ───────
        final startTime = _parse12hTime(_str(rawM['time']) ?? '12:00 am');

        results.add(MeetingDto(
          externalId:    id,
          name:          _str(rawM['name']) ?? '(Unnamed Meeting)',
          fellowship:    _fellowship,
          locationName:  locName.isNotEmpty ? locName : null,
          latitude:      lat,
          longitude:     lng,
          address:       address.isNotEmpty ? address : null,
          city:          city,
          state:         state,
          country:       'US',
          weekday:       _toInt(rawM['day']) ?? 0,
          startTime:     startTime,
          typeCodes:     types,
          isOnline:      isOnline,
          isHybrid:      isHybrid,
        ));
      }
    }

    return results;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converts a 12-hour time string to 24-hour "HH:mm" format.
  ///
  /// Examples:
  ///   "6:00 am"  → "06:00"
  ///   "6:30 pm"  → "18:30"
  ///   "12:00 pm" → "12:00"
  ///   "12:00 am" → "00:00"
  static String _parse12hTime(String raw) {
    final lower = raw.toLowerCase().trim();
    final isPm  = lower.contains('pm');
    final clean = lower.replaceAll(RegExp(r'[^0-9:]'), '').trim();
    final colon = clean.indexOf(':');
    if (colon == -1) return '00:00';

    var h   = int.tryParse(clean.substring(0, colon)) ?? 0;
    final m = clean.substring(colon + 1).padRight(2, '0').substring(0, 2);

    if (isPm && h != 12) h += 12;
    if (!isPm && h == 12) h = 0;

    return '${h.toString().padLeft(2, '0')}:$m';
  }

  /// Extracts city and state from a formatted address like
  /// "123 Main St, Boston, MA 02101, USA".
  static (String city, String state) _parseCityState(String address) {
    if (address.isEmpty) return ('', '');
    final parts = address.split(', ');
    // parts example: ["123 Main St", "Boston", "MA 02101", "USA"]
    // With no street:  ["Boston", "MA 02101", "USA"]
    if (parts.length < 3) return ('', '');
    final city     = parts[parts.length - 3];
    final stateZip = parts[parts.length - 2]; // "MA 02101"
    final state    = stateZip.split(' ').first.toUpperCase();
    return (city, state);
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
