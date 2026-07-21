import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../data/repositories/meetings_repository.dart';
import '../adapters/meeting_source_adapter.dart';
import '../adapters/tsml_adapter.dart';
import '../adapters/tsml_page_adapter.dart';
import '../adapters/oiaa_adapter.dart';
import '../adapters/na_meeting_guide_adapter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Per-source status model
// ─────────────────────────────────────────────────────────────────────────────

/// Status for a single adapter during or after a sync run.
class SourceSyncResult {
  final String sourceId;
  final String displayName;
  final List<String> fellowships;
  final int added;
  final int updated;
  final String? errorMessage;

  const SourceSyncResult({
    required this.sourceId,
    required this.displayName,
    required this.fellowships,
    this.added = 0,
    this.updated = 0,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;
  int get total => added + updated;

  SourceSyncResult withError(String msg) => SourceSyncResult(
        sourceId: sourceId,
        displayName: displayName,
        fellowships: fellowships,
        errorMessage: msg,
      );

  SourceSyncResult withCounts(int a, int u) => SourceSyncResult(
        sourceId: sourceId,
        displayName: displayName,
        fellowships: fellowships,
        added: a,
        updated: u,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Overall sync state
// ─────────────────────────────────────────────────────────────────────────────

enum SyncStatus { idle, syncing, success, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final int added;
  final int updated;

  /// Per-adapter results from the most recent sync run.
  final List<SourceSyncResult> sourceResults;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.errorMessage,
    this.added = 0,
    this.updated = 0,
    this.sourceResults = const [],
  });

  bool get isIdle => status == SyncStatus.idle;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasError => status == SyncStatus.error;
  bool get neverSynced => lastSyncAt == null;

  int get totalMeetings => sourceResults.fold(0, (s, r) => s + r.total);

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? errorMessage,
    int? added,
    int? updated,
    List<SourceSyncResult>? sourceResults,
  }) =>
      SyncState(
        status: status ?? this.status,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        errorMessage: errorMessage,
        added: added ?? this.added,
        updated: updated ?? this.updated,
        sourceResults: sourceResults ?? this.sourceResults,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Adapter registry
// ─────────────────────────────────────────────────────────────────────────────

/// All registered meeting source adapters.
///
/// ─────────────────────────────────────────────────────────────────────────
/// ARCHITECTURE NOTE (2025)
/// ─────────────────────────────────────────────────────────────────────────
/// The previous centralized API (api.aa-intergroup.org) has been
/// decommissioned. The AA meeting data ecosystem now uses a *distributed*
/// model: each regional intergroup runs their own WordPress site with the
/// "12 Step Meeting List" (TSML) plugin, which exposes meetings at:
///
///   GET https://<intergroup-site>/wp-json/twelvesteplist/v2/meetings
///
/// The [TsmlAdapter] handles any such endpoint.
///
/// ### Adding your local intergroup
/// 1. Find your AA intergroup or area website (e.g. https://ct-aa.org)
/// 2. Check namespaces: GET <site>/wp-json/ — look for "tsml" in the list
/// 3. Verify public access: GET <site>/wp-json/tsml/meetings
/// 4. Add a TsmlAdapter entry below with a unique [id] and your site's URL.
///
/// ### OIAA online meetings
/// The Online Intergroup of AA (aa-intergroup.org) is handled by
/// [OiaaAdapter] which fetches from the Code4Recovery OML static JSON feed
/// at data.aa-intergroup.org (8 000+ online meetings, no pagination needed).
///
/// ### NA meetings
/// [NaMeetingGuideAdapter] instances require a verified regional URL.
/// Uncomment and supply a [customBaseUrl] for your target region.
final meetingAdaptersProvider = Provider<List<MeetingSourceAdapter>>((ref) {
  return [
    // ── OIAA — online-only AA meetings (nationwide) ───────────────────────
    // Fetches from data.aa-intergroup.org OML JSON feed (~8 000 meetings).
    // OIAA uses Code4Recovery's "Online Meeting List" component, NOT TSML.
    OiaaAdapter(),

    // ── New England in-person AA meetings via TSML ────────────────────────
    //
    // The "12 Step Meeting List" WordPress plugin registers its REST API
    // under the `tsml` namespace:
    //   GET <site>/wp-json/tsml/meetings
    //
    // Status verified Mar 2026 by direct API inspection:
    //   ✅ active   — public feed confirmed, meeting count shown
    //   🔒 commented — TSML present but admin set feed to "Restricted" (403)
    //   ❌ commented — site does not use TSML plugin
    //
    // ── Eastern Massachusetts (Boston CSO)  ✅ 300 meetings ─────────────
    // aaboston.org has the TSML REST feed locked to "Restricted", but all
    // meeting data is embedded as `var locations = {...}` in the HTML page.
    // TsmlPageAdapter extracts that JavaScript variable directly.
    TsmlPageAdapter(
      id:          'tsml-page-ema-boston',
      name:        'AA — Eastern Massachusetts (Boston)',
      meetingsUrl: 'https://aaboston.org/meetings',
    ),

    // ── Western Massachusetts  ✅ 492 meetings ───────────────────────────
    // The public site is westernmassaa.org but meeting data lives on the
    // companion domain westernmassaa.net which has a public TSML REST feed.
    TsmlAdapter(
      id:      'tsml-aa-wma',
      name:    'AA — Western Massachusetts',
      baseUrl: 'https://westernmassaa.net',
    ),

    // ── Connecticut  ✅ 1,906 meetings ───────────────────────────────────

    TsmlAdapter(
      id:      'tsml-aa-ct',
      name:    'AA — Connecticut',
      baseUrl: 'https://ct-aa.org',
    ),

    // ── Rhode Island  ✅ 720 meetings ────────────────────────────────────

    TsmlAdapter(
      id:      'tsml-aa-ri',
      name:    'AA — Rhode Island',
      baseUrl: 'https://rhodeisland-aa.org',
    ),

    // ── Vermont  ✅ 524 meetings ──────────────────────────────────────────

    TsmlAdapter(
      id:      'tsml-aa-vt',
      name:    'AA — Vermont',
      baseUrl: 'https://aavt.org',
    ),

    // ── New Hampshire  🔒 feed restricted ────────────────────────────────
    // nhaa.net — TSML installed, feed returns HTTP 403.
    // TsmlAdapter(
    //   id:      'tsml-aa-nh',
    //   name:    'AA — New Hampshire',
    //   baseUrl: 'https://nhaa.net',
    // ),

    // ── Maine  ❌ no TSML plugin ──────────────────────────────────────────
    // maineaa.org uses EventEspresso — no /wp-json/tsml namespace at all.
    // TsmlAdapter(
    //   id:      'tsml-aa-me',
    //   name:    'AA — Maine',
    //   baseUrl: 'https://maineaa.org',
    // ),

    // ── Western Massachusetts  ❌ no TSML endpoint ───────────────────────
    // westernmassaa.org has no /wp-json/tsml/meetings route.
    // TsmlAdapter(
    //   id:      'tsml-aa-wma',
    //   name:    'AA — Western Massachusetts',
    //   baseUrl: 'https://westernmassaa.org',
    // ),

    // ── Berkshire County MA  ❌ no TSML endpoint ─────────────────────────
    // berkshireintergroup.org has no /wp-json/tsml/meetings route.
    // TsmlAdapter(
    //   id:      'tsml-aa-berkshire',
    //   name:    'AA — Berkshire County MA',
    //   baseUrl: 'https://www.berkshireintergroup.org',
    // ),

    // ══════════════════════════════════════════════════════════════════════════
    // EXPANSION BACKLOG — AA intergroup TSML feeds (audited Mar 2026)
    // Status:  ✅ public feed confirmed  🔒 TSML present but restricted (403)
    //          ❌ no TSML plugin found   ⚠️  inconclusive / needs re-check
    //
    // See docs/aa-coverage-tracker.xlsx for the full research spreadsheet,
    // outreach status, estimated meeting counts, and the 5-phase action plan.
    // ══════════════════════════════════════════════════════════════════════════

    // ── PHASE 1 — Active ✅ (feeds verified public Mar 2026) ──────────────
    //    ~2,350+ meetings added across 11 sites.

    // ┌─ Mid-Atlantic ───────────────────────────────────────────────────────
    TsmlAdapter(
      id:      'tsml-aa-nyc',
      name:    'AA — Greater New York',
      baseUrl: 'https://www.nyintergroup.org',
    ),

    TsmlAdapter(
      id:      'tsml-aa-baltimore',
      name:    'AA — Baltimore',
      baseUrl: 'https://www.baltimoreaa.org',
    ),

    // ┌─ Southeast ──────────────────────────────────────────────────────────
    TsmlAdapter(
      id:      'tsml-aa-atlanta',
      name:    'AA — Metro Atlanta',
      baseUrl: 'https://www.atlantaaa.org',
    ),

    TsmlAdapter(
      id:      'tsml-aa-nashville',
      name:    'AA — Middle Tennessee (Nashville)',
      baseUrl: 'https://www.aanashville.org',
    ),

    // ┌─ South (Texas) ──────────────────────────────────────────────────────
    TsmlAdapter(
      id:      'tsml-aa-dallas',
      name:    'AA — Dallas',
      baseUrl: 'https://www.aadallas.org',
    ),

    TsmlAdapter(
      id:      'tsml-aa-sanantonio',
      name:    'AA — San Antonio',
      baseUrl: 'https://www.aasanantonio.org',
    ),

    // ┌─ Mountain ───────────────────────────────────────────────────────────
    TsmlAdapter(
      id:      'tsml-aa-phoenix',
      name:    'AA — Phoenix',
      baseUrl: 'https://www.aaphoenix.org',
    ),

    TsmlAdapter(
      id:      'tsml-aa-tucson',
      name:    'AA — Tucson',
      baseUrl: 'https://www.aatucson.org',
    ),

    // ┌─ Pacific Northwest ──────────────────────────────────────────────────
    TsmlAdapter(
      id:      'tsml-aa-seattle',
      name:    'AA — Seattle',
      baseUrl: 'https://www.seattleaa.org',
    ),

    // ┌─ California ─────────────────────────────────────────────────────────
    TsmlAdapter(
      id:      'tsml-aa-oakland',
      name:    'AA — Oakland / East Bay',
      baseUrl: 'https://www.aaoakland.org',
    ),

    TsmlAdapter(
      id:      'tsml-aa-sandiego',
      name:    'AA — San Diego',
      baseUrl: 'https://www.aasandiego.org',
    ),

    // ── PHASE 2 — Restricted feeds; open via webmaster outreach ───────────
    //    TSML is installed but feed is set to "Restricted".
    //    Ask the intergroup webmaster to change the setting at:
    //      WP Admin → Meetings → Settings → General → "Export meetings feed"
    //    Once open, move to Phase 1 above and uncomment.
    //
    // 🔒 New Hampshire   — https://nhaa.net/contact
    // TsmlAdapter(id: 'tsml-aa-nh', name: 'AA — New Hampshire',
    //             baseUrl: 'https://nhaa.net'),
    //
    // 🔒 Charlotte NC (Metrolina Intergroup)
    // TsmlAdapter(id: 'tsml-aa-charlotte', name: 'AA — Charlotte (Metrolina)',
    //             baseUrl: 'https://www.charlotteaa.org'),
    //
    // 🔒 Chicago IL (403 on wp-json root itself — high-value target)
    // TsmlAdapter(id: 'tsml-aa-chicago', name: 'AA — Chicago',
    //             baseUrl: 'https://www.chicagoaa.org'),
    //
    // 🔒 Denver CO — DACC (401 on wp-json)
    // TsmlAdapter(id: 'tsml-aa-denver', name: 'AA — Denver',
    //             baseUrl: 'https://www.daccaa.org'),
    //
    // 🔒 New Orleans LA
    // TsmlAdapter(id: 'tsml-aa-neworleans', name: 'AA — New Orleans',
    //             baseUrl: 'https://www.aaneworleans.org'),
    //
    // 🔒 Sacramento CA
    // TsmlAdapter(id: 'tsml-aa-sacramento', name: 'AA — Sacramento',
    //             baseUrl: 'https://www.aasacramento.org'),

    // ── PHASE 3 — Active ✅ (verified Mar 2026 on re-check) ───────────────
    //    www.aa-dc.org had a TLS error; no-www resolves cleanly.
    //    portlandaa.org / oregonaa.org both refused; pdxaa.org is the live site.

    // ┌─ Mid-Atlantic ───────────────────────────────────────────────────────
    // ✅ ~101 meetings — use bare domain (www has a TLS cert mismatch)
    TsmlAdapter(
      id:      'tsml-aa-dc',
      name:    'AA — Washington DC',
      baseUrl: 'https://aa-dc.org',
    ),

    // ┌─ Pacific Northwest ──────────────────────────────────────────────────
    // ✅ ~150+ meetings — pdxaa.org is the canonical Portland intergroup site
    TsmlAdapter(
      id:      'tsml-aa-portland',
      name:    'AA — Portland',
      baseUrl: 'https://www.pdxaa.org',
    ),

    // ── PHASE 3 — Resolved ❌ (moved to Phase 4 after exhausting alternates) ─
    //
    // ❌ Houston TX — all three domains failed (timeout / 500 / ECONNREFUSED):
    //      www.aahouston.org, aahouston.org, aacentralofficehouston.org
    //
    // ❌ Kansas City MO — all domains JS-redirect to /lander (no API exposed):
    //      www.aakc.org, aakc.org, www.kcintergroup.org
    //
    // ❌ Los Angeles CA — laintergroup.org → laintergroup.com (no wp-json);
    //      aala.org JS-redirect to /lander; no TSML found on any alternate.
    //      LA is the biggest missing metro — worth a direct outreach to
    //      Los Angeles Intergroup asking them to adopt TSML or share a feed.
    //
    // ❌ San Francisco CA — aasf.org redirects to aasfmarin.org which has
    //      WordPress REST but uses Tribe Events, not TSML.
    //      sfaa.org = 404; aasf.com = 404; intergroup.org = JS redirect.

    // ── PHASE 4 — Active ✅ (found via alternate domain, verified Mar 2026) ──
    //    These were originally listed with wrong canonical domains.
    //    All confirmed public TSML REST feeds.

    // ┌─ Midwest ────────────────────────────────────────────────────────────
    // ✅ ~450 KB data — canonical domain is indyaa.org, not aaindianapolis.org
    TsmlAdapter(
      id:      'tsml-aa-indianapolis',
      name:    'AA — Indianapolis',
      baseUrl: 'https://www.indyaa.org',
    ),

    // ✅ ~960 KB data — canonical domain is aastl.org, not aastlouis.org
    TsmlAdapter(
      id:      'tsml-aa-stlouis',
      name:    'AA — St. Louis',
      baseUrl: 'https://aastl.org',
    ),

    // ┌─ South (Texas) ──────────────────────────────────────────────────────
    // ✅ ~1 MB data — canonical domain is austinaa.org, not aaaustin.org
    TsmlAdapter(
      id:      'tsml-aa-austin',
      name:    'AA — Austin',
      baseUrl: 'https://austinaa.org',
    ),

    // ── PHASE 4 — No accessible data feed; outreach needed ────────────────
    //    Domain audited Mar 2026.  Options remaining:
    //    a) Contact intergroup to adopt TSML or publish a JSON export
    //    b) Re-check annually — many interlgroups are updating their tech
    //
    // ❌ Maine ME          — maineaa.org (EventEspresso; /wp-json/em/v2/events → 404)
    // ❌ Philadelphia PA   — philaaa.org, philaintergroup.org, aaphiladelphia.org
    //                        all ECONNREFUSED; no reachable domain found Mar 2026
    // ❌ Northern NJ       — nnjaa.org accessible but is a static site (no WP/API)
    // ❌ Western PA        — wpaaa.org (ad-hijacked domain); wpaaintergroup.org → 404
    // ❌ Miami FL          — aaofmiami.org, aamiami.org all ECONNREFUSED Mar 2026
    // ❌ Orlando FL        — aaorlando.org, aaorlandofl.org all ECONNREFUSED Mar 2026
    // ❌ Tampa Bay FL      — tampabayaa.org → usaftba.org (no TSML); tbaa.org → 404
    // ❌ Minneapolis MN    — aaminneapolis.org (Tribe Events plugin; only 49 one-off
    //                        special events, no recurring weekly meeting calendar)
    // ❌ Detroit MI        — aadetroit.org, aadetroitintergroup.org all ECONNREFUSED
    // ❌ Cleveland OH      — aacleveland.org empty response; no alternate found
    // ❌ Columbus OH       — aacolumbus.org ECONNREFUSED; columbusintergroup.org → 404
    // ❌ Milwaukee WI      — aamilwaukee.org → aamilwaukee.com (static site, no WP)
    // ❌ Salt Lake City UT — aaslc.org ECONNREFUSED; slcaa.org, saltlakecityaa.org → 404
    // ❌ Albuquerque NM    — aaalbuquerque.org ECONNREFUSED; no alternate found
    // ❌ Orange County CA  — aaorangecounty.org ECONNREFUSED; no alternate found
    // ❌ Houston TX        — aahouston.org + aacentraloffice.org all timeout/refused
    // ❌ Kansas City MO    — aakc.org + kcintergroup.org (JS redirect wall)
    // ❌ Los Angeles CA    — laintergroup.com (no wp-json); aala.org (JS redirect)
    //                        Highest-value missing metro; recommend direct outreach.
    // ❌ San Francisco CA  — aasf.org → aasfmarin.org (Tribe Events, not TSML)

    // ══════════════════════════════════════════════════════════════════════════
    // CANADA — AA intergroup TSML feeds (audited Mar 2026)
    // ══════════════════════════════════════════════════════════════════════════
    //
    // Canadian feeds follow identical TSML v2 conventions as US feeds.
    // Country code is 'CA'; province abbreviations are used for `state`.
    //
    // Status:  ✅ public feed confirmed  🔒 TSML present but restricted (403)
    //          ❌ no TSML plugin found   ⚠️  inconclusive / needs re-check
    //
    // See docs/aa-coverage-tracker.xlsx (Canada tab) for the full research
    // spreadsheet, outreach status, and the 5-phase action plan.
    //
    // ── CANADA ACTIVE ✅ (feeds verified public Mar 2026) ──────────────────
    //    ~2,493 meetings across 4 provinces.

    // ┌─ British Columbia & Yukon ───────────────────────────────────────────
    // ✅ ~1,131 meetings — bcyukonaa.org covers BC + Yukon territory
    TsmlAdapter(
      id:      'tsml-aa-bcyukon',
      name:    'AA — British Columbia & Yukon',
      baseUrl: 'https://www.bcyukonaa.org',
    ),

    // ┌─ Alberta ────────────────────────────────────────────────────────────
    // ✅ ~453 meetings — Calgary Intergroup serves greater Alberta
    TsmlAdapter(
      id:      'tsml-aa-calgary',
      name:    'AA — Calgary',
      baseUrl: 'https://www.calgaryaa.org',
    ),

    // ┌─ Manitoba ───────────────────────────────────────────────────────────
    // ✅ ~414 meetings — use bare domain (www triggers a redirect that some
    //    HTTP clients don't follow; bare domain responds directly)
    TsmlAdapter(
      id:      'tsml-aa-manitoba',
      name:    'AA — Manitoba',
      baseUrl: 'https://aamanitoba.org',
    ),

    // ┌─ Ontario ────────────────────────────────────────────────────────────
    // ✅ ~495 meetings — Toronto Central Intergroup
    TsmlAdapter(
      id:      'tsml-aa-toronto',
      name:    'AA — Toronto',
      baseUrl: 'https://www.aatoronto.org',
    ),

    // ┌─ Saskatchewan ───────────────────────────────────────────────────────
    // ✅ ~85 meetings — Regina Intergroup; no separate Saskatoon feed found
    TsmlAdapter(
      id:      'tsml-aa-regina',
      name:    'AA — Regina (Saskatchewan)',
      baseUrl: 'https://aaregina.org',
    ),

    // ┌─ Atlantic Canada ────────────────────────────────────────────────────
    // ✅ ~89 meetings — Halifax Intergroup covers Nova Scotia
    TsmlAdapter(
      id:      'tsml-aa-halifax',
      name:    'AA — Halifax (Nova Scotia)',
      baseUrl: 'https://www.aahalifax.org',
    ),

    // ── CANADA RESTRICTED / NO FEED — outreach targets ────────────────────
    //
    // 🔒 aa.org (national, US/CA combined) — TSML confirmed, 403 on feed
    //
    // ❌ aaswo.org — Southwestern Ontario — WordPress REST present; no TSML ns
    // ❌ aanb.org  — New Brunswick — WordPress REST present; no TSML ns
    //
    // ❌ Montréal QC — aaqc.ca JS-redirects to /lander (no API);
    //        aa-montreal.qc.ca, aamontreal.org, intergroupe.qc.ca,
    //        intergroupe-aa.ca all ECONNREFUSED / DNS failure Mar 2026.
    //        Largest missing Canadian city. French-language meetings expected.
    //        Recommend direct outreach to Montréal intergroup.
    //
    // ❌ Ottawa ON  — aaottawa.org, ottawaaintergroup.org, aacentralottawa.org,
    //        ottawavalleyaa.org, ottawaaa.com, aaottawagatineau.org
    //        all DNS failure Mar 2026. No reachable domain found.
    //
    // ❌ Edmonton AB — edmontonaa.org, edmontonintergroup.com, aaalberta.org,
    //        aacentralalberta.org, edmontonaa.ca all DNS failure Mar 2026.
    //
    // ⚠️  Québec City QC — aaquebc.org, intergroupe-quebec.org, aa-quebec.qc.ca
    //        all ECONNREFUSED. French-language meetings expected once found.
    // ⚠️  Winnipeg MB  — aamanitoba.org covers Manitoba; no city-specific feed
    // ⚠️  Newfoundland  — aanlnl.ca, aanl.ca all ECONNREFUSED Mar 2026

    // ── HOW TO ADD A NEW INTERGROUP ────────────────────────────────────────
    // 1. GET <site>/wp-json/  → check for "tsml" in the namespaces array.
    // 2. GET <site>/wp-json/tsml/meetings → JSON array = public; 403 = restricted.
    // 3. If public: add a TsmlAdapter here with a unique id and baseUrl.
    //    If restricted: contact the webmaster (see Phase 2 note above).
    // TsmlAdapter(
    //   id:      'tsml-aa-<unique-id>',
    //   name:    'AA — <City/Region>',
    //   baseUrl: 'https://your-intergroup-site.org',
    // ),

    // ══════════════════════════════════════════════════════════════════════════
    // NA — New England (NERNA)
    // ══════════════════════════════════════════════════════════════════════════
    //
    // NERNA (New England Region of NA) covers Massachusetts + Rhode Island.
    //   Primary website: https://nerna.org
    //   Areas: Boston, Cape Cod, Central MA, Greater Providence, Greater
    //          Worcester, Martha's Vineyard, Metro West, Nantucket, Northeast
    //          MA, Southeast MA, South Shore, Pioneer Valley, Western MA.
    //
    // TSML status verified Mar 2026:
    //   🔒 nerna.org — "12 Step Meeting List" plugin confirmed installed,
    //      but the REST feed is set to "Restricted" (HTTP 403).
    //      To enable: ask NERNA's webmaster to set the feed to "Public" at
    //      WP Admin → Meetings → Settings → General → "Export meetings feed".
    //      Contact form: https://nerna.org/contact-us/
    //
    // ── Option A: TSML direct (preferred once feed is open) ──────────────
    // TsmlAdapter(
    //   id:        'tsml-na-nerna',
    //   name:      'NA — New England (NERNA)',
    //   baseUrl:   'https://nerna.org',
    //   fellowship: 'NA',
    // ),
    //
    // ── Option B: NAWS state-filtered (pending NAWS endpoint update) ──────
    // The NAWS bulk-query endpoint at na.org/meetingsearch/searchresults.php
    // returns HTTP 404 as of Mar 2026.  Uncomment below once a replacement
    // URL is confirmed; pass it via customBaseUrl.
    //
    // NaMeetingGuideAdapter.nerna(
    //   customBaseUrl: 'https://<verified-naws-or-nerna-endpoint>',
    // ),

    // ══════════════════════════════════════════════════════════════════════════
    // NA — Northern New England (NNERNA)
    // ══════════════════════════════════════════════════════════════════════════
    //
    // NNERNA covers NH, ME, and VT.
    //   Primary website: https://nnerna.org
    //
    // TSML status verified Mar 2026:
    //   ❌ nnerna.org — WordPress REST API present but no "tsml" namespace;
    //      site uses Events Manager plugin for meetings instead.
    //      Monitor for future TSML migration or a standalone JSON export.
    //
    // NaMeetingGuideAdapter.nnerna(
    //   customBaseUrl: 'https://<verified-nnerna-endpoint>',
    // ),
  ];
});

final meetingSyncProvider =
    StateNotifierProvider<MeetingSyncNotifier, SyncState>((ref) {
  return MeetingSyncNotifier(
    adapters: ref.watch(meetingAdaptersProvider),
    repo: ref.watch(meetingsRepositoryProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class MeetingSyncNotifier extends StateNotifier<SyncState> {
  final List<MeetingSourceAdapter> adapters;
  final MeetingsRepository repo;

  MeetingSyncNotifier({required this.adapters, required this.repo})
      : super(const SyncState()) {
    _loadLastSyncTime();
  }

  // ── Boot ─────────────────────────────────────────────────────────────────

  Future<void> _loadLastSyncTime() async {
    if (adapters.isEmpty) return;

    // Find the most recent lastSyncAt across all registered adapters.
    DateTime? latest;
    for (final a in adapters) {
      final meta = await repo.getSourceMeta(a.sourceId);
      if (meta?.lastSyncAt != null) {
        if (latest == null || meta!.lastSyncAt!.isAfter(latest)) {
          latest = meta!.lastSyncAt;
        }
      }
    }

    if (latest != null) {
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: latest,
      );
    }
  }

  // ── Public ────────────────────────────────────────────────────────────────

  /// Trigger a sync across all *enabled* adapters.
  /// Uses delta (updated_since) when a previous sync exists for the adapter
  /// and it was run within the last 7 days; otherwise does a full fetch.
  Future<void> triggerSync() async {
    if (state.isSyncing) return;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    int totalAdded = 0;
    int totalUpdated = 0;
    String? lastError;
    final results = <SourceSyncResult>[];

    for (final adapter in adapters) {
      // Skip adapters that are explicitly disabled.
      if (!adapter.enabledByDefault) continue;

      final placeholder = SourceSyncResult(
        sourceId: adapter.sourceId,
        displayName: adapter.displayName,
        fellowships: adapter.fellowships,
      );

      try {
        final counts = await _syncAdapter(adapter);
        totalAdded += counts.$1;
        totalUpdated += counts.$2;
        results.add(placeholder.withCounts(counts.$1, counts.$2));
      } catch (e) {
        final errMsg = '$e';
        lastError = 'Error syncing ${adapter.displayName}: $errMsg';
        await repo.recordSyncError(
            adapter.sourceId, adapter.displayName, errMsg);
        results.add(placeholder.withError(errMsg));
      }
    }

    state = state.copyWith(
      status: lastError != null ? SyncStatus.error : SyncStatus.success,
      lastSyncAt: DateTime.now(),
      errorMessage: lastError,
      added: totalAdded,
      updated: totalUpdated,
      sourceResults: results,
    );
  }

  /// Auto-sync if data is stale — called silently on app launch and resume.
  ///
  /// Triggers a full sync if:
  ///   • The app has never synced before ([state.neverSynced]), or
  ///   • The most recent sync completed more than [staleAfter] ago.
  ///
  /// This is a no-op when a sync is already running. The sync itself runs
  /// asynchronously; callers should not await it when invoking from lifecycle
  /// callbacks, to avoid blocking the UI.
  Future<void> autoSyncIfStale({
    Duration staleAfter = const Duration(hours: 24),
  }) async {
    if (state.isSyncing) return;
    final lastSync = state.lastSyncAt;
    final isStale =
        lastSync == null || DateTime.now().difference(lastSync) > staleAfter;
    if (isStale) await triggerSync();
  }

  /// Force-enable and sync a specific adapter (e.g. after user toggles it on).
  Future<void> syncAdapter(String sourceId) async {
    final adapter = adapters.firstWhere(
      (a) => a.sourceId == sourceId,
      orElse: () => throw ArgumentError('Unknown sourceId: $sourceId'),
    );
    if (state.isSyncing) return;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);
    try {
      final counts = await _syncAdapter(adapter);
      state = state.copyWith(
        status: SyncStatus.success,
        lastSyncAt: DateTime.now(),
        added: counts.$1,
        updated: counts.$2,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: 'Error syncing ${adapter.displayName}: $e',
      );
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<(int, int)> _syncAdapter(MeetingSourceAdapter adapter) async {
    final meta = await repo.getSourceMeta(adapter.sourceId);
    final lastSync = meta?.lastSyncAt;

    // Use delta sync if we've synced this source before, within the past 7 days.
    final useDelta = lastSync != null &&
        DateTime.now().difference(lastSync).inDays < 7;

    final dtos = useDelta
        ? await adapter.fetchUpdatedSince(lastSync)
        : await adapter.fetchAll();

    final counts = await repo.upsertMeetings(adapter.sourceId, dtos);

    await repo.saveSourceMeta(SyncMetasCompanion(
      sourceId: Value(adapter.sourceId),
      displayName: Value(adapter.displayName),
      lastSyncAt: Value(DateTime.now()),
      totalMeetings: Value(counts.$1 + counts.$2),
      syncError: const Value(null),
    ));

    return counts;
  }
}
