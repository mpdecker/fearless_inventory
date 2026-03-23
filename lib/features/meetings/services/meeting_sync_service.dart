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

    // ── Greater New York  (nearby, uncomment if needed) ──────────────────
    // TsmlAdapter(
    //   id:      'tsml-aa-nyc',
    //   name:    'AA — Greater New York',
    //   baseUrl: 'https://www.nyintergroup.org',
    // ),

    // ── HOW TO ADD YOUR LOCAL INTERGROUP ─────────────────────────────────
    // 1. Open <site>/wp-json/ and check for "tsml" in the namespaces list.
    // 2. Try GET <site>/wp-json/tsml/meetings — public feeds return a JSON array.
    //    A 403 "feed_restricted" means the admin needs to set it to Public.
    // TsmlAdapter(
    //   id:      'tsml-aa-<unique-id>',
    //   name:    'AA — <Your City/Region>',
    //   baseUrl: 'https://your-intergroup-site.org',
    // ),

    // ── NA — scaffolded; uncomment with a verified regional URL ───────────
    // NaMeetingGuideAdapter.newEngland(
    //   customBaseUrl: 'https://<na-region-site>/wp-json/twelvesteplist/v2/meetings',
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
        ? await adapter.fetchUpdatedSince(lastSync!)
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
