/// Normalised meeting DTO produced by every adapter before DB insertion.
/// All adapters must map their source-specific JSON to this shape.
class MeetingDto {
  final String externalId;
  final String name;
  final String fellowship;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String city;
  final String state;
  final String country;

  /// 0 = Sunday … 6 = Saturday
  final int weekday;

  /// 24-h "HH:mm" wall-clock start time
  final String startTime;
  final int? durationMinutes;

  /// Standard type codes — see [kMeetingTypeCodes] for the full map.
  final List<String> typeCodes;

  final bool isOnline;
  final bool isHybrid;
  final String? conferenceUrl;
  final String? conferencePhone;

  /// 'zoom' | 'phone' | 'teams' | 'google-meet' | null
  final String? onlinePlatform;
  final String? notes;
  final DateTime? lastUpdated;

  /// BCP-47 language code for the meeting's primary language.
  /// Common values: 'en' (English), 'es' (Spanish), 'fr' (French).
  /// Defaults to 'en'. Parsed from the TSML `lang` field when present;
  /// otherwise inferred from type codes or defaulted to English.
  final String language;

  const MeetingDto({
    required this.externalId,
    required this.name,
    this.fellowship = 'AA',
    this.locationName,
    this.latitude,
    this.longitude,
    this.address,
    required this.city,
    required this.state,
    this.country = 'US',
    required this.weekday,
    required this.startTime,
    this.durationMinutes,
    this.typeCodes = const [],
    this.isOnline = false,
    this.isHybrid = false,
    this.conferenceUrl,
    this.conferencePhone,
    this.onlinePlatform,
    this.notes,
    this.lastUpdated,
    this.language = 'en',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Type codes — AA (TSML / Meeting Guide convention)
// ─────────────────────────────────────────────────────────────────────────────

/// Human-readable labels for the standard AA Meeting Guide type codes.
const kMeetingTypeCodes = <String, String>{
  // Format
  'O': 'Open',
  'C': 'Closed',
  'H': 'Hybrid',
  'ONL': 'Online',
  'TC': 'Temp Closed',
  // Focus / format
  'BB': 'Big Book',
  'ST': 'Step Study',
  'SP': 'Speaker',
  'D': 'Discussion',
  'BE': 'Beginners',
  'LIT': 'Literature',
  'MED': 'Meditation',
  'T': 'Traditions',
  'TR': 'Trusted Servants',
  'W': "Women's",
  'M': "Men's",
  'Y': 'Young People',
  'SD': 'Speaker + Discussion',
  'SWG': 'Step/Tradition/Concept',
  'BA': 'Babysitting Available',
  'ASL': 'ASL Interpretation',
  'X': 'Wheelchair Access',
  'XB': 'Wheelchair-accessible Bathroom',
  'XT': 'Wheelchair Accessible Transit',
  'DN': 'Digital Newcomer',
  'CAN': 'Candlelight',
  'FF': 'Fragrance Free',
  'NDG': 'Non-Discrimination',
  'NS': 'No Smoking',
  'PE': 'Pets Welcome',
  // ── Language-specific meetings ────────────────────────────────────────
  // These type codes signal a non-English primary language.
  // When present, the adapter also sets the `language` field on MeetingDto.
  'FR': 'French (Français)',
  'ES': 'Spanish (Español)',
};

// ─────────────────────────────────────────────────────────────────────────────
// Type codes — NA (NAWS convention)
// ─────────────────────────────────────────────────────────────────────────────

/// Human-readable labels for NA meeting type codes.
const kNaTypeCodes = <String, String>{
  'O': 'Open',
  'C': 'Closed',
  'BT': 'Basic Text',
  'JFT': 'Just For Today',
  'SP': 'Speaker',
  'D': 'Discussion',
  'IP': 'Informational Pamphlet',
  'WC': 'World Convention',
  'St': 'Step Study',
  'Tr': 'Traditions Study',
  'IW': 'It Works',
  'LGBTQ': 'LGBTQ+',
  'W': "Women's",
  'M': "Men's",
  'YP': 'Young People',
  'NS': 'Non-Smoking',
  'WA': 'Wheelchair Access',
  'TC': 'Temp Closed',
  'ONL': 'Online',
  'H': 'Hybrid',
};

/// Combined lookup across all fellowships.
/// Not const because AA and NA share several code keys (e.g. 'O', 'C', 'SP');
/// the later NA entry wins for shared keys, which is fine — the labels are
/// identical or equivalent. Using `final` avoids the duplicate-key compile error.
final kAllTypeCodes = <String, String>{
  ...kMeetingTypeCodes,
  ...kNaTypeCodes,
};

// ─────────────────────────────────────────────────────────────────────────────
// US Region presets (for Meeting Guide regional adapters)
// ─────────────────────────────────────────────────────────────────────────────

/// Named US geographic regions mapped to their state abbreviations.
/// Used by [MeetingGuideAdapter] and [NaMeetingGuideAdapter] to limit
/// the geographic scope of each sync operation.
const kUsRegions = <String, List<String>>{
  'new_england': ['MA', 'CT', 'ME', 'NH', 'RI', 'VT'],
  'mid_atlantic': ['NY', 'NJ', 'PA', 'DE', 'MD', 'DC', 'VA', 'WV'],
  'southeast': ['NC', 'SC', 'GA', 'FL', 'AL', 'MS', 'TN', 'KY', 'AR'],
  'midwest': ['OH', 'MI', 'IN', 'IL', 'WI', 'MN', 'IA', 'MO', 'ND', 'SD', 'NE', 'KS'],
  'south': ['TX', 'OK', 'LA'],
  'mountain': ['MT', 'WY', 'CO', 'NM', 'AZ', 'UT', 'NV', 'ID'],
  'pacific_northwest': ['WA', 'OR'],
  'california': ['CA'],
  'alaska_hawaii': ['AK', 'HI'],

  // ── NA regional boundaries (differ from the AA regions above) ────────────
  // NERNA  = New England Region of NA  — MA + RI
  // NNERNA = Northern New England Region of NA — NH, ME, VT
  // Connecticut NA has its own separate region (not part of NERNA).
  'nerna':  ['MA', 'RI'],
  'nnerna': ['NH', 'ME', 'VT'],
};

/// All US state abbreviations — use sparingly; results in very large fetches.
const kAllUsStates = [
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL',
  'GA', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME',
  'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH',
  'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI',
  'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
];

// ─────────────────────────────────────────────────────────────────────────────
// Abstract adapter interface
// ─────────────────────────────────────────────────────────────────────────────

/// Every meeting source (AA Meeting Guide, OIAA, NA, OA, etc.) implements this.
/// The sync service calls these methods; nothing above the adapter knows
/// which source it is talking to.
abstract class MeetingSourceAdapter {
  /// Stable identifier stored in the DB as `source_id`.
  /// Examples: 'meeting-guide-aa-ne', 'oiaa-online', 'meeting-guide-na-ne'
  String get sourceId;

  /// Human-readable label shown in UI.
  String get displayName;

  /// Fellowship(s) this adapter covers — e.g. ['AA'], ['NA'], ['AA', 'NA'].
  List<String> get fellowships;

  /// Whether this adapter is enabled by default (can be overridden in settings).
  bool get enabledByDefault => true;

  /// Fetch the complete meeting list for this adapter's configured scope.
  Future<List<MeetingDto>> fetchAll();

  /// Fetch only meetings updated since [since].
  /// Adapters that don't support delta sync should fall back to [fetchAll].
  Future<List<MeetingDto>> fetchUpdatedSince(DateTime since);
}
