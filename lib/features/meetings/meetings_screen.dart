import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/database/database.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../data/repositories/meetings_repository.dart';
import 'adapters/meeting_source_adapter.dart';
import 'services/meeting_sync_service.dart';
import 'services/meeting_calendar_service.dart';
import 'services/meeting_notification_service.dart';
import 'services/location_service.dart';
import 'map_launch_uri.dart';
import 'providers/meetings_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fellowship style palette
// ─────────────────────────────────────────────────────────────────────────────

class _FellowshipStyle {
  final String label;
  final Color background;
  final Color foreground;
  final Color border;
  const _FellowshipStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });
}

const _kFellowshipStyles = <String, _FellowshipStyle>{
  'AA': _FellowshipStyle(
    label: 'AA',
    background: Color(0xFFE8F0FE),
    foreground: Color(0xFF1A56DB),
    border: Color(0xFFBFD5F8),
  ),
  'NA': _FellowshipStyle(
    label: 'NA',
    background: Color(0xFFE6F9F1),
    foreground: Color(0xFF0E7A4E),
    border: Color(0xFFABE8CC),
  ),
  'OA': _FellowshipStyle(
    label: 'OA',
    background: Color(0xFFFFF3E8),
    foreground: Color(0xFFB45309),
    border: Color(0xFFFFCF94),
  ),
};

const _kDefaultFellowshipStyle = _FellowshipStyle(
  label: '—',
  background: Color(0xFFF3F4F6),
  foreground: Color(0xFF4B5563),
  border: Color(0xFFD1D5DB),
);

_FellowshipStyle _fellowshipStyle(String? fellowship) =>
    _kFellowshipStyles[fellowship?.toUpperCase()] ?? _kDefaultFellowshipStyle;

// ─────────────────────────────────────────────────────────────────────────────
// Root screen  (3 tabs: Finder | Nearby | My Meetings)
// ─────────────────────────────────────────────────────────────────────────────

class MeetingsScreen extends ConsumerStatefulWidget {
  const MeetingsScreen({super.key});

  @override
  ConsumerState<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends ConsumerState<MeetingsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addObserver(this);

    // Auto-sync in the background after the first frame renders so the UI
    // isn't blocked. Sync only fires if data is stale (never synced or
    // last sync > 24 hours ago); otherwise it's a no-op.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetingSyncProvider.notifier).autoSyncIfStale();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check staleness when the app comes back to the foreground.
    if (state == AppLifecycleState.resumed) {
      ref.read(meetingSyncProvider.notifier).autoSyncIfStale();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(meetingSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        actions: [
          // Sources info / status panel
          IconButton(
            icon: const Icon(Icons.dns_outlined),
            tooltip: 'Data sources',
            onPressed: () => _showSourcesSheet(context, ref),
          ),
          _SyncButton(sync: sync),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.search_outlined), text: 'Finder'),
            Tab(icon: Icon(Icons.near_me_outlined), text: 'Nearby'),
            Tab(icon: Icon(Icons.bookmark_outline), text: 'My Meetings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FinderTab(),
          _NearbyTab(),
          _MyMeetingsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              onPressed: () => _showLogAttendanceSheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Log Attendance'),
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sync button (app bar action)
// ─────────────────────────────────────────────────────────────────────────────

class _SyncButton extends ConsumerWidget {
  final SyncState sync;
  const _SyncButton({required this.sync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sync.isSyncing) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      icon: Icon(
        sync.hasError ? Icons.sync_problem_outlined : Icons.sync_outlined,
        color: sync.hasError ? Colors.red : null,
      ),
      tooltip: sync.lastSyncAt != null
          ? 'Last synced ${_fmt(sync.lastSyncAt!)}'
          : 'Sync meetings',
      onPressed: () => ref.read(meetingSyncProvider.notifier).triggerSync(),
    );
  }

  static String _fmt(DateTime dt) => DateFormat('MMM d, h:mm a').format(dt);
}

// ─────────────────────────────────────────────────────────────────────────────
// Finder tab
// ─────────────────────────────────────────────────────────────────────────────

class _FinderTab extends HookConsumerWidget {
  const _FinderTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allMeetingsProvider);
    final filtered = ref.watch(filteredMeetingsProvider);
    final filter = ref.watch(meetingFilterProvider);
    final searchCtrl = useTextEditingController();

    return Column(
      children: [
        // ── Search bar + filter button ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (q) => ref
                      .read(meetingFilterProvider.notifier)
                      .state = filter.copyWith(query: q),
                  decoration: InputDecoration(
                    hintText: 'Search meetings, locations…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: filter.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchCtrl.clear();
                              ref.read(meetingFilterProvider.notifier).state =
                                  filter.copyWith(query: '');
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _FilterButton(filter: filter),
            ],
          ),
        ),

        // ── Content ─────────────────────────────────────────────────────
        Expanded(
          child: allAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (all) {
              if (all.isEmpty) {
                return _EmptyState(
                  onSync: () => ref
                      .read(meetingSyncProvider.notifier)
                      .triggerSync(),
                );
              }
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'No meetings match your filters.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _MeetingCard(meeting: filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nearby tab
// ─────────────────────────────────────────────────────────────────────────────

// Radius preset options shown as chips.
const _kRadiusOptions = <String, double?>{
  'Any': null,
  '5 mi': 5,
  '10 mi': 10,
  '25 mi': 25,
  '50 mi': 50,
  '100 mi': 100,
};

class _NearbyTab extends HookConsumerWidget {
  const _NearbyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeLocationProvider);
    final allAsync = ref.watch(allMeetingsProvider);
    final query = ref.watch(locationQueryProvider);
    final radius = ref.watch(distanceRadiusMiProvider);
    final filter = ref.watch(meetingFilterProvider);

    // Whether a custom query is typed and geocoding is in flight.
    final geocodeAsync = ref.watch(geocodedLocationProvider);
    final isGeocoding =
        query.trim().isNotEmpty && geocodeAsync.isLoading;

    return Column(
      children: [
        // ── Location input ──────────────────────────────────────────────
        _LocationInputBar(isGeocoding: isGeocoding),

        // ── Radius chips + filter button ────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in _kRadiusOptions.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(entry.key),
                            selected: radius == entry.value,
                            onSelected: (_) => ref
                                .read(distanceRadiusMiProvider.notifier)
                                .state = entry.value,
                            visualDensity: VisualDensity.compact,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: radius == entry.value
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _FilterButton(filter: filter),
            ],
          ),
        ),

        // ── Content ─────────────────────────────────────────────────────
        Expanded(
          child: activeAsync.when(
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    query.trim().isNotEmpty
                        ? 'Looking up "${query.trim()}"…'
                        : 'Getting your location…',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            error: (e, _) => _LocationError(
              message: 'Could not resolve location: $e',
              onRetry: () {
                ref.refresh(userLocationProvider);
                ref.refresh(geocodedLocationProvider);
              },
            ),
            data: (active) {
              if (active == null) {
                // Show a friendlier state that also surfaces the text input.
                return _LocationUnavailable(
                  hasCustomQuery: query.trim().isNotEmpty,
                  onRetryGps: () {
                    ref.read(locationQueryProvider.notifier).state = '';
                    // Request permission explicitly on retry (same policy as
                    // the GPS button — never auto-request on tab open).
                    () async {
                      LocationPermission perm =
                          await Geolocator.checkPermission();
                      if (perm == LocationPermission.denied) {
                        perm = await Geolocator.requestPermission();
                      }
                      ref.refresh(userLocationProvider);
                    }();
                  },
                );
              }

              return allAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (all) {
                  if (all.isEmpty) {
                    return _EmptyState(
                      onSync: () => ref
                          .read(meetingSyncProvider.notifier)
                          .triggerSync(),
                    );
                  }

                  // Apply shared filters (day, time, type, format, fellowship).
                  final filtered = filter.apply(all);

                  // Compute distances and sort.
                  final withCoords = <_DistancedMeeting>[];
                  final noCoords = <Meeting>[];

                  for (final m in filtered) {
                    if (m.latitude != null && m.longitude != null) {
                      final km = haversineKm(
                        active.latitude,
                        active.longitude,
                        m.latitude!,
                        m.longitude!,
                      );
                      withCoords.add(_DistancedMeeting(m, km));
                    } else {
                      noCoords.add(m);
                    }
                  }
                  withCoords.sort(
                      (a, b) => a.distanceKm!.compareTo(b.distanceKm!));

                  // Apply radius filter.
                  final radiusKm =
                      radius != null ? miToKm(radius) : null;
                  final visible = radiusKm != null
                      ? withCoords
                          .where((d) => d.distanceKm! <= radiusKm)
                          .toList()
                      : [
                          ...withCoords,
                          ...noCoords.map((m) => _DistancedMeeting(m, null)),
                        ];

                  final hiddenCount = radiusKm != null
                      ? (withCoords.length - visible.length) +
                          noCoords.length
                      : 0;

                  return Column(
                    children: [
                      // Active location banner
                      _ActiveLocationBanner(
                        active: active,
                        visibleCount: visible.length,
                        hiddenCount: hiddenCount,
                        onRefresh: () {
                          if (active.fromGps) {
                            ref.refresh(userLocationProvider);
                          } else {
                            ref.refresh(geocodedLocationProvider);
                          }
                        },
                      ),
                      Expanded(
                        child: visible.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Text(
                                    radius != null
                                        ? 'No meetings within $radius mi of ${active.label}.'
                                        : 'No meetings with location data.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        height: 1.5),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    12, 8, 12, 100),
                                itemCount: visible.length,
                                itemBuilder: (_, i) => _MeetingCard(
                                  meeting: visible[i].meeting,
                                  distanceKm: visible[i].distanceKm,
                                ),
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Location input bar ────────────────────────────────────────────────────────

class _LocationInputBar extends HookConsumerWidget {
  final bool isGeocoding;
  const _LocationInputBar({required this.isGeocoding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(locationQueryProvider);
    final ctrl = useTextEditingController();

    // Keep controller text in sync when cleared externally.
    useEffect(() {
      if (query.isEmpty && ctrl.text.isNotEmpty) ctrl.clear();
      return null;
    }, [query]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                final trimmed = v.trim();
                ref.read(locationQueryProvider.notifier).state = trimmed;
                if (trimmed.isNotEmpty) {
                  ref.refresh(geocodedLocationProvider);
                }
              },
              decoration: InputDecoration(
                hintText: 'Zip code or city name…',
                prefixIcon: isGeocoding
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search_outlined, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: 'Clear — use GPS',
                        onPressed: () {
                          ctrl.clear();
                          ref.read(locationQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // GPS button — explicitly request permission then acquire location.
          Tooltip(
            message: query.isEmpty ? 'Using GPS' : 'Use GPS instead',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                ctrl.clear();
                ref.read(locationQueryProvider.notifier).state = '';
                // Only show the system permission dialog when the user
                // explicitly taps this button, not on tab open.
                LocationPermission perm = await Geolocator.checkPermission();
                if (perm == LocationPermission.denied) {
                  perm = await Geolocator.requestPermission();
                }
                ref.refresh(userLocationProvider);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: query.isEmpty
                      ? Colors.blue.shade600
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.my_location,
                  size: 20,
                  color: query.isEmpty ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active location banner ───────────────────────────────────────────────────

class _ActiveLocationBanner extends StatelessWidget {
  final ActiveLocation active;
  final int visibleCount;
  final int hiddenCount;
  final VoidCallback onRefresh;

  const _ActiveLocationBanner({
    required this.active,
    required this.visibleCount,
    required this.hiddenCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final label = active.fromGps
        ? 'GPS — ${active.label}'
        : active.label;
    final countText = hiddenCount > 0
        ? '$visibleCount shown, $hiddenCount outside filter'
        : '$visibleCount meeting${visibleCount == 1 ? '' : 's'} with location';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(
            active.fromGps ? Icons.my_location : Icons.location_on_outlined,
            size: 15,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  countText,
                  style: TextStyle(
                      color: Colors.blue.shade600, fontSize: 11),
                ),
                if (active.fromGps && active.reducedLocationAccuracy) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Approximate location is on — meeting distances may be less accurate. '
                    'You can enable Precise Location in Settings or search by zip or city.',
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 10,
                        height: 1.25),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.blue.shade700,
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

// ── Location unavailable state ───────────────────────────────────────────────

class _LocationUnavailable extends StatelessWidget {
  final bool hasCustomQuery;
  final VoidCallback onRetryGps;
  const _LocationUnavailable(
      {required this.hasCustomQuery, required this.onRetryGps});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              hasCustomQuery
                  ? 'Location not found. Try a different zip code or city name.'
                  : 'Location unavailable. Enter a zip code or city above, or enable GPS.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, height: 1.5, fontSize: 14),
            ),
            if (!hasCustomQuery) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetryGps,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Retry GPS'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DistancedMeeting {
  final Meeting meeting;
  final double? distanceKm;
  const _DistancedMeeting(this.meeting, this.distanceKm);
}

class _LocationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LocationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter button (icon + badge) — opens the filter sheet
// ─────────────────────────────────────────────────────────────────────────────

const _kDayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _kFilterTypes = ['O', 'C', 'BB', 'ST', 'SP', 'BE', 'MED'];

class _FilterButton extends StatelessWidget {
  final MeetingFilter filter;
  const _FilterButton({required this.filter});

  @override
  Widget build(BuildContext context) {
    final count = filter.activeCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Filters',
          style: IconButton.styleFrom(
            backgroundColor: count > 0
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.grey.shade100,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _showFilterSheet(context),
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter sheet (grouped bottom sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(meetingFilterProvider);

    void update(MeetingFilter f) =>
        ref.read(meetingFilterProvider.notifier).state = f;

    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
            child: Row(
              children: [
                Text('Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const Spacer(),
                TextButton(
                  onPressed: () => update(const MeetingFilter()),
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Scrollable body ──────────────────────────────────────────
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                // ── SCHEDULE ──────────────────────────────────────────
                _SectionHeader(icon: Icons.calendar_today_outlined,
                    label: 'Schedule'),
                const SizedBox(height: 8),

                // Day of week
                Text('Day',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withAlpha(153),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < 7; i++)
                      _FilterChip(
                        label: _kDayLabels[i],
                        selected: filter.weekday == i,
                        onTap: () => update(filter.copyWith(
                          weekday: filter.weekday == i ? null : i,
                        )),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Time of day
                Text('Time of day',
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withAlpha(153),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tod in MeetingTimeOfDay.values)
                      _FilterChip(
                        label: tod.label,
                        icon: tod.icon,
                        selected: filter.timeOfDay == tod,
                        onTap: () => update(filter.copyWith(
                          timeOfDay:
                              filter.timeOfDay == tod ? null : tod,
                        )),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                // ── FORMAT ───────────────────────────────────────────
                _SectionHeader(icon: Icons.place_outlined, label: 'Format'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FilterChip(
                      label: 'Any',
                      selected: filter.format == MeetingFormat.all,
                      onTap: () =>
                          update(filter.copyWith(format: MeetingFormat.all)),
                    ),
                    _FilterChip(
                      label: 'In-person',
                      icon: Icons.location_on_outlined,
                      selected: filter.format == MeetingFormat.inPerson,
                      onTap: () => update(
                          filter.copyWith(format: MeetingFormat.inPerson)),
                    ),
                    _FilterChip(
                      label: 'Online',
                      icon: Icons.videocam_outlined,
                      selected: filter.format == MeetingFormat.online,
                      onTap: () => update(
                          filter.copyWith(format: MeetingFormat.online)),
                    ),
                    _FilterChip(
                      label: 'Hybrid',
                      icon: Icons.people_outlined,
                      selected: filter.format == MeetingFormat.hybrid,
                      onTap: () => update(
                          filter.copyWith(format: MeetingFormat.hybrid)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // ── MEETING TYPE ─────────────────────────────────────
                _SectionHeader(
                    icon: Icons.label_outline, label: 'Meeting type'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final code in _kFilterTypes)
                      _FilterChip(
                        label: kAllTypeCodes[code] ?? code,
                        selected: filter.typeCodes.contains(code),
                        onTap: () {
                          final codes = Set<String>.from(filter.typeCodes);
                          codes.contains(code)
                              ? codes.remove(code)
                              : codes.add(code);
                          update(filter.copyWith(typeCodes: codes));
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                // ── FELLOWSHIP ───────────────────────────────────────
                _SectionHeader(
                    icon: Icons.groups_outlined, label: 'Fellowship'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: filter.fellowship == null,
                      onTap: () => update(
                          filter.copyWith(fellowship: null)),
                    ),
                    _FilterChip(
                      label: 'AA',
                      selected: filter.fellowship == 'AA',
                      onTap: () => update(filter.copyWith(
                        fellowship:
                            filter.fellowship == 'AA' ? null : 'AA',
                      )),
                    ),
                    _FilterChip(
                      label: 'NA',
                      selected: filter.fellowship == 'NA',
                      onTap: () => update(filter.copyWith(
                        fellowship:
                            filter.fellowship == 'NA' ? null : 'NA',
                      )),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // ── LANGUAGE ─────────────────────────────────────────
                _SectionHeader(
                    icon: Icons.language_outlined, label: 'Language'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: filter.language == null,
                      onTap: () =>
                          update(filter.copyWith(language: null)),
                    ),
                    _FilterChip(
                      label: 'English',
                      selected: filter.language == 'en',
                      onTap: () => update(filter.copyWith(
                        language:
                            filter.language == 'en' ? null : 'en',
                      )),
                    ),
                    _FilterChip(
                      label: 'Español',
                      selected: filter.language == 'es',
                      onTap: () => update(filter.copyWith(
                        language:
                            filter.language == 'es' ? null : 'es',
                      )),
                    ),
                    _FilterChip(
                      label: 'Français',
                      selected: filter.language == 'fr',
                      onTap: () => update(filter.copyWith(
                        language:
                            filter.language == 'fr' ? null : 'fr',
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter sheet helpers ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.primary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: icon != null
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13),
              const SizedBox(width: 4),
              Text(label),
            ])
          : Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      labelStyle: const TextStyle(fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting card
// ─────────────────────────────────────────────────────────────────────────────

class _MeetingCard extends ConsumerWidget {
  final Meeting meeting;
  final double? distanceKm; // null = no location data
  const _MeetingCard({required this.meeting, this.distanceKm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = parseMeetingTypeCodes(meeting.typeCodes);
    final timeStr = _formatTime(meeting.startTime);
    final dayStr = _kDayLabels[meeting.weekday % 7];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: meeting.isHomeGroup
              ? Colors.orange.shade300
              : Colors.grey.shade200,
          width: meeting.isHomeGroup ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMeetingDetail(context, ref, meeting),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Day/time column ──────────────────────────────────────
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    Text(
                      dayStr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // ── Main content ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meeting.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Fellowship badge (AA / NA / OA)
                        _FellowshipBadge(fellowship: meeting.fellowship),
                        const SizedBox(width: 4),
                        if (meeting.isHomeGroup)
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(Icons.home,
                                size: 14, color: Colors.orange.shade700),
                          ),
                        if (meeting.isPlannedAttendance)
                          Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(Icons.event_repeat,
                                size: 14, color: Colors.teal.shade700),
                          ),
                        if (meeting.isOnline || meeting.isHybrid)
                          _OnlineBadge(isHybrid: meeting.isHybrid),
                        if (meeting.isBookmarked && !meeting.isHomeGroup)
                          const Icon(Icons.bookmark,
                              size: 16, color: Colors.orange),
                      ],
                    ),
                    // Location + distance
                    if (meeting.locationName != null ||
                        meeting.city.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                [
                                  if (meeting.locationName != null)
                                    meeting.locationName!,
                                  meeting.city,
                                ].join(', '),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (distanceKm != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  formatDistance(distanceKm!),
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (types.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: types
                              .take(4)
                              .map((c) => _TypeChip(code: c))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// My Meetings tab
// ─────────────────────────────────────────────────────────────────────────────

class _MyMeetingsTab extends ConsumerWidget {
  const _MyMeetingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAsync = ref.watch(bookmarkedMeetingsProvider);
    final attendanceAsync = ref.watch(attendanceLogsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      children: [
        // ── Home Groups / Bookmarked ─────────────────────────────────────
        _sectionHeader(context, 'SAVED MEETINGS', Icons.bookmark_outlined),
        const SizedBox(height: 8),
        bookmarkedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (meetings) => meetings.isEmpty
              ? _emptySection(
                  'No saved meetings yet.',
                  'Tap the bookmark icon on any meeting to save it here.',
                )
              : Column(
                  children: meetings
                      .map((m) => _MeetingCard(meeting: m))
                      .toList(),
                ),
        ),

        const SizedBox(height: 20),

        // ── Attendance log ───────────────────────────────────────────────
        _sectionHeader(context, 'ATTENDANCE LOG', Icons.checklist_outlined),
        const SizedBox(height: 8),
        attendanceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (logs) => logs.isEmpty
              ? _emptySection(
                  'No attendance logged yet.',
                  'Use the button below to log when you attend a meeting.',
                )
              : Column(
                  children: logs
                      .map((l) => _AttendanceTile(log: l))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _emptySection(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendance tile
// ─────────────────────────────────────────────────────────────────────────────

class _AttendanceTile extends ConsumerWidget {
  final AttendanceLog log;
  const _AttendanceTile({required this.log});

  static final _fmt = DateFormat('EEE, MMM d · h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.groups_outlined,
              color: Colors.orange.shade700, size: 20),
        ),
        title: Text(log.meetingName,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fmt.format(log.attendedAt),
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (log.sharedAtMeeting ||
                log.hasSponsorContact ||
                log.hasServiceWork)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: [
                    if (log.sharedAtMeeting)
                      _badge('Shared', Colors.indigo),
                    if (log.hasSponsorContact)
                      _badge('Sponsor', Colors.purple),
                    if (log.hasServiceWork)
                      _badge('Service', Colors.teal),
                  ],
                ),
              ),
            if (log.notes != null && log.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  log.notes!,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline,
              size: 18, color: Colors.grey),
          onPressed: () =>
              ref.read(meetingsRepositoryProvider).deleteAttendance(log.id),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Meeting detail bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showMeetingDetail(
    BuildContext context, WidgetRef ref, Meeting meeting) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _MeetingDetailSheet(meeting: meeting),
    ),
  );
}

class _MeetingDetailSheet extends HookConsumerWidget {
  final Meeting meeting;
  const _MeetingDetailSheet({required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = useState(meeting.isBookmarked);
    final isHomeGroup = useState(meeting.isHomeGroup);
    final isPlanned = useState(meeting.isPlannedAttendance);
    final types = parseMeetingTypeCodes(meeting.typeCodes);
    final dayStr = _kDayLabels[meeting.weekday % 7];
    final timeStr = _formatTime(meeting.startTime);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          // ── Drag handle ──────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // ── Title row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _FellowshipBadge(fellowship: meeting.fellowship, large: true),
                  ],
                ),
              ),
              // Bookmark toggle
              IconButton(
                icon: Icon(
                  isBookmarked.value
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: isBookmarked.value ? Colors.orange : null,
                ),
                onPressed: () async {
                  final newVal = !isBookmarked.value;
                  isBookmarked.value = newVal;
                  // If un-bookmarking, also clear home group
                  if (!newVal && isHomeGroup.value) {
                    isHomeGroup.value = false;
                    await ref
                        .read(meetingsRepositoryProvider)
                        .setHomeGroup(meeting.id, value: false);
                  }
                  await ref
                      .read(meetingsRepositoryProvider)
                      .toggleBookmark(meeting);
                },
              ),
            ],
          ),

          // ── Home group toggle ────────────────────────────────────────
          if (isBookmarked.value)
            Row(
              children: [
                Icon(Icons.home_outlined,
                    size: 16,
                    color: isHomeGroup.value
                        ? Colors.orange.shade700
                        : Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Home group',
                  style: TextStyle(
                    fontSize: 13,
                    color: isHomeGroup.value
                        ? Colors.orange.shade700
                        : null,
                    fontWeight: isHomeGroup.value
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isHomeGroup.value,
                  activeColor: Colors.orange.shade700,
                  onChanged: (v) async {
                    isHomeGroup.value = v;
                    await ref
                        .read(meetingsRepositoryProvider)
                        .setHomeGroup(meeting.id, value: v);

                    // Offer to auto-schedule calendar events
                    if (v && context.mounted) {
                      _offerCalendarAutoSchedule(context, ref, meeting);
                    }
                  },
                ),
              ],
            ),

          // ── Plan to attend (Step 12 calendar) ───────────────────────
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.event_repeat_outlined,
                size: 16,
                color: isPlanned.value
                    ? Colors.teal.shade700
                    : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                'Plan to attend (Step 12 calendar)',
                style: TextStyle(
                  fontSize: 13,
                  color: isPlanned.value ? Colors.teal.shade700 : null,
                  fontWeight: isPlanned.value
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const Spacer(),
              Switch(
                value: isPlanned.value,
                activeColor: Colors.teal.shade700,
                onChanged: (v) async {
                  isPlanned.value = v;
                  await ref
                      .read(meetingsRepositoryProvider)
                      .setPlannedAttendance(meeting.id, value: v);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Type badges ──────────────────────────────────────────────
          if (types.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ...types.map((c) => _TypeChip(code: c, large: true)),
                if (meeting.isOnline || meeting.isHybrid)
                  _OnlineBadge(isHybrid: meeting.isHybrid, large: true),
              ],
            ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // ── Metadata rows ────────────────────────────────────────────
          _detailRow(
            Icons.calendar_today_outlined,
            '$dayStr at $timeStr',
            meeting.durationMinutes != null
                ? '${meeting.durationMinutes} min'
                : null,
          ),
          if (meeting.locationName != null)
            _detailRow(
              Icons.location_on_outlined,
              meeting.locationName!,
              meeting.address,
              color: Colors.blue,
              onTap: meeting.latitude != null
                  ? () => _openMaps(meeting)
                  : null,
            ),
          if (meeting.address != null && meeting.locationName == null)
            _detailRow(
              Icons.location_on_outlined,
              meeting.address!,
              meeting.city,
              color: Colors.blue,
              onTap: () => _openMaps(meeting),
            ),
          if (meeting.conferenceUrl != null)
            _detailRow(
              Icons.videocam_outlined,
              'Join online',
              meeting.conferenceUrl,
              color: Colors.indigo,
              onTap: () => _launchConference(context, meeting),
            ),
          if (meeting.conferencePhone != null)
            _detailRow(
              Icons.phone_outlined,
              meeting.conferencePhone!,
              'Dial in',
              color: Colors.green,
              onTap: () => _launchPhone(meeting.conferencePhone!),
            ),
          if (meeting.notes != null && meeting.notes!.isNotEmpty)
            _detailRow(
              Icons.notes_outlined,
              meeting.notes!,
              null,
            ),

          const SizedBox(height: 20),

          // ── Join button ───────────────────────────────────────────────
          if (meeting.isOnline || meeting.isHybrid) ...[
            ElevatedButton.icon(
              onPressed: () => _launchConference(context, meeting),
              icon: Icon(
                meeting.onlinePlatform == 'zoom'
                    ? Icons.video_camera_front_outlined
                    : Icons.videocam_outlined,
              ),
              label: Text(
                meeting.onlinePlatform == 'zoom'
                    ? 'Open in Zoom'
                    : 'Join Meeting',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Get Directions ────────────────────────────────────────────
          if (!meeting.isOnline && meeting.latitude != null) ...[
            OutlinedButton.icon(
              onPressed: () => _openMaps(meeting),
              icon: const Icon(Icons.directions_outlined),
              label: const Text('Get Directions'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Add to Calendar ───────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddToCalendarSheet(context, ref, meeting);
            },
            icon: const Icon(Icons.event_outlined),
            label: const Text('Add to Step 12 Calendar'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),

          // ── Set Reminder ──────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showSetReminderSheet(context, ref, meeting);
            },
            icon: const Icon(Icons.notifications_outlined),
            label: const Text('Set Reminder'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: Colors.amber.shade800,
              side: BorderSide(color: Colors.amber.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),

          // ── Log Attendance ────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showLogAttendanceSheet(context, ref, meeting: meeting);
            },
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Log Attendance'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String primary,
    String? secondary, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18,
              color: color ?? Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(primary,
                    style: TextStyle(
                        fontSize: 14,
                        color: onTap != null
                            ? Colors.blue.shade700
                            : null)),
                if (secondary != null)
                  Text(secondary,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right,
                size: 16, color: Colors.grey),
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

/// Show a dialog offering to auto-schedule weekly calendar events when a
/// meeting is marked as a home group.
void _offerCalendarAutoSchedule(
    BuildContext context, WidgetRef ref, Meeting meeting) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add to Calendar?'),
      content: Text(
        'Would you like to add weekly Step 12 calendar events for '
        '"${meeting.name}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final svc = ref.read(meetingCalendarServiceProvider);
            final count = await svc.addRecurring(meeting, weeks: 12);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Added $count weekly events to your Step 12 calendar'),
                  backgroundColor: Colors.green.shade700,
                ),
              );
            }
          },
          child: const Text('Add 12 Weeks'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final svc = ref.read(meetingCalendarServiceProvider);
            final count = await svc.addRecurring(meeting, weeks: 52);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Added $count weekly events to your Step 12 calendar'),
                  backgroundColor: Colors.green.shade700,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add 1 Year'),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Add to Calendar sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showAddToCalendarSheet(
    BuildContext context, WidgetRef ref, Meeting meeting) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _AddToCalendarSheet(meeting: meeting),
    ),
  );
}

class _AddToCalendarSheet extends HookConsumerWidget {
  final Meeting meeting;
  const _AddToCalendarSheet({required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saving = useState(false);
    final dayStr = _kDayLabels[meeting.weekday % 7];
    final timeStr = _formatTime(meeting.startTime);
    final nextDate =
        nextMeetingOccurrence(meeting.weekday, meeting.startTime);
    final nextFmt = DateFormat('EEE, MMM d').format(nextDate);

    Future<void> add(int weeks) async {
      saving.value = true;
      try {
        final svc = ref.read(meetingCalendarServiceProvider);
        final count =
            weeks == 1 ? 1 : await svc.addRecurring(meeting, weeks: weeks);
        if (weeks == 1) await svc.addSingle(meeting);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              weeks == 1
                  ? 'Added to calendar: $nextFmt'
                  : 'Added $count weekly events to Step 12 calendar',
            ),
            backgroundColor: Colors.green.shade700,
          ));
        }
      } finally {
        saving.value = false;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Row(
              children: [
                Icon(Icons.event_outlined, color: Colors.green.shade700),
                const SizedBox(width: 10),
                const Text(
                  'Add to Step 12 Calendar',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              meeting.name,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            Text(
              '$dayStr at $timeStr · Next: $nextFmt',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 24),

            if (saving.value)
              const Center(child: CircularProgressIndicator())
            else ...[
              _calendarOption(
                context,
                icon: Icons.looks_one_outlined,
                title: 'This occurrence only',
                subtitle: nextFmt,
                color: Colors.green,
                onTap: () => add(1),
              ),
              const SizedBox(height: 10),
              _calendarOption(
                context,
                icon: Icons.repeat_outlined,
                title: 'Weekly — 12 weeks',
                subtitle: 'Adds the next 12 occurrences',
                color: Colors.teal,
                onTap: () => add(12),
              ),
              const SizedBox(height: 10),
              _calendarOption(
                context,
                icon: Icons.all_inclusive_outlined,
                title: 'Weekly — full year',
                subtitle: 'Adds 52 recurring events',
                color: Colors.indigo,
                onTap: () => add(52),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _calendarOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 15)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Set Reminder sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showSetReminderSheet(
    BuildContext context, WidgetRef ref, Meeting meeting) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _SetReminderSheet(meeting: meeting),
    ),
  );
}

class _SetReminderSheet extends HookConsumerWidget {
  final Meeting meeting;
  const _SetReminderSheet({required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        useState<ReminderOffset?>(ReminderOffset.thirtyMin);
    final saving = useState(false);

    final nextDate =
        nextMeetingOccurrence(meeting.weekday, meeting.startTime);

    Future<void> schedule() async {
      if (selected.value == null) return;
      saving.value = true;
      try {
        final svc = ref.read(meetingNotificationServiceProvider);
        final ok = await svc.scheduleWeeklyReminder(
          meeting,
          nextDate,
          selected.value!,
        );
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              ok
                  ? 'Reminder set: ${selected.value!.label} before each ${_kDayLabels[meeting.weekday % 7]} meeting'
                  : 'Could not schedule — the meeting starts too soon.',
            ),
            backgroundColor: ok ? Colors.amber.shade800 : Colors.red,
          ));
        }
      } finally {
        saving.value = false;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Row(
              children: [
                Icon(Icons.notifications_outlined,
                    color: Colors.amber.shade800),
                const SizedBox(width: 10),
                const Text(
                  'Set Meeting Reminder',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              meeting.name,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            Text(
              'Repeats every ${_kDayLabels[meeting.weekday % 7]} at ${_formatTime(meeting.startTime)}',
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 20),

            const Text('Remind me:',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),

            for (final offset in ReminderOffset.values)
              RadioListTile<ReminderOffset>(
                dense: true,
                value: offset,
                groupValue: selected.value,
                onChanged: (v) => selected.value = v,
                title: Text(offset.label,
                    style: const TextStyle(fontSize: 14)),
                activeColor: Colors.amber.shade800,
                contentPadding: EdgeInsets.zero,
              ),

            const SizedBox(height: 16),

            if (saving.value)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: selected.value != null ? schedule : null,
                icon: const Icon(Icons.alarm_outlined),
                label: const Text('Set Weekly Reminder'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

            const SizedBox(height: 10),

            // Cancel all reminders for this meeting
            TextButton.icon(
              onPressed: () async {
                await ref
                    .read(meetingNotificationServiceProvider)
                    .cancelAll(meeting.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('All reminders cancelled for this meeting'),
                  ));
                }
              },
              icon: const Icon(Icons.alarm_off_outlined, size: 16),
              label: const Text('Cancel all reminders'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Log Attendance sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showLogAttendanceSheet(BuildContext context, WidgetRef ref,
    {Meeting? meeting}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _LogAttendanceSheet(meeting: meeting),
    ),
  );
}

class _LogAttendanceSheet extends HookConsumerWidget {
  final Meeting? meeting;
  const _LogAttendanceSheet({this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesCtrl = useTextEditingController();
    final shared = useState(false);
    final sponsorContact = useState(false);
    final serviceWork = useState(false);
    final attendedAt = useState(DateTime.now());

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Log Attendance',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              meeting?.name ?? 'Meeting',
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // ── Date/time picker ────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showAdaptiveAppDatePicker(
                  context: context,
                  initialDate: attendedAt.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) {
                  attendedAt.value = DateTime(d.year, d.month, d.day,
                      attendedAt.value.hour, attendedAt.value.minute);
                }
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(DateFormat('EEE, MMM d, yyyy')
                  .format(attendedAt.value)),
            ),

            const SizedBox(height: 16),

            // ── Recovery activity checkboxes ─────────────────────────
            const Text('Recovery activity',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            _checkbox(
                'Shared at this meeting', shared.value,
                (v) => shared.value = v),
            _checkbox(
                'Connected with sponsor / sponsee',
                sponsorContact.value,
                (v) => sponsorContact.value = v),
            _checkbox(
                'Did service work', serviceWork.value,
                (v) => serviceWork.value = v),

            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────────────
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Save ─────────────────────────────────────────────────
            ElevatedButton(
              onPressed: () async {
                await ref.read(meetingsRepositoryProvider).logAttendance(
                      AttendanceLogsCompanion(
                        meetingId: Value(meeting?.id),
                        meetingName:
                            Value(meeting?.name ?? 'Manual entry'),
                        attendedAt: Value(attendedAt.value),
                        notes: Value(notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim()),
                        sharedAtMeeting: Value(shared.value),
                        hasSponsorContact: Value(sponsorContact.value),
                        hasServiceWork: Value(serviceWork.value),
                      ),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Attendance',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkbox(
      String label, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      dense: true,
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state (no meetings synced yet)
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends ConsumerWidget {
  final VoidCallback onSync;
  const _EmptyState({required this.onSync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(meetingSyncProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined,
                size: 72, color: Colors.orange.shade200),
            const SizedBox(height: 20),
            const Text(
              'No meetings loaded yet',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Sync to load AA meetings for New England. '
              'More regions and fellowships coming soon.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: sync.isSyncing ? null : onSync,
              icon: sync.isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_outlined),
              label: Text(sync.isSyncing ? 'Syncing…' : 'Find Meetings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (sync.hasError) ...[
              const SizedBox(height: 14),
              Text(
                _friendlyError(sync.errorMessage ?? 'Sync failed'),
                style:
                    const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error message helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Converts a raw exception string (SocketException, TimeoutException, etc.)
/// into a short, human-readable message suitable for display in the UI.
String _friendlyError(String raw) {
  final lower = raw.toLowerCase();
  if (lower.contains('failed host lookup') ||
      lower.contains('no address associated') ||
      lower.contains('socketexception') ||
      lower.contains('errno = 7') ||
      lower.contains('network is unreachable')) {
    return 'No internet connection — check Wi-Fi or cellular and try again.';
  }
  if (lower.contains('timed out') || lower.contains('timeout')) {
    return 'Connection timed out — the server may be slow. Try again later.';
  }
  if (lower.contains('handshake') || lower.contains('certificate') ||
      lower.contains('ssl') || lower.contains('tls')) {
    return 'Secure connection failed — try again or check date/time settings.';
  }
  if (lower.contains('404')) return 'Meeting source not found (404). The API may have moved.';
  if (lower.contains('429')) return 'Rate limited — please wait a few minutes and try again.';
  if (lower.contains('5')) {
    // Rough check for 5xx
    final match = RegExp(r'\b5\d{2}\b').firstMatch(raw);
    if (match != null) return 'Server error (${match.group(0)}) — try again later.';
  }
  // Truncate long raw messages so they fit in the card.
  if (raw.length > 80) return '${raw.substring(0, 77)}…';
  return raw;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sources bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

void _showSourcesSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: const _SourcesSheet(),
    ),
  );
}

class _SourcesSheet extends ConsumerWidget {
  const _SourcesSheet();

  static final _fmt = DateFormat('MMM d, h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(meetingSyncProvider);
    final adapters = ref.watch(meetingAdaptersProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          Row(
            children: [
              const Icon(Icons.dns_outlined, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Meeting Data Sources',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (sync.isSyncing)
                const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                IconButton(
                  icon: const Icon(Icons.sync_outlined, size: 20),
                  tooltip: 'Sync all',
                  onPressed: () =>
                      ref.read(meetingSyncProvider.notifier).triggerSync(),
                ),
            ],
          ),

          if (sync.lastSyncAt != null) ...[
            const SizedBox(height: 2),
            Text(
              'Last synced: ${_fmt.format(sync.lastSyncAt!)}  ·  '
              '${sync.added} new, ${sync.updated} updated',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 12),
            ),
          ],

          const SizedBox(height: 16),

          // ── Per-adapter cards ─────────────────────────────────────────
          for (final adapter in adapters) ...[
            _SourceCard(
              adapter: adapter,
              result: sync.sourceResults
                  .where((r) => r.sourceId == adapter.sourceId)
                  .firstOrNull,
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ── Add local intergroup ──────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => _showAddIntergroupHelp(context),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Add your local intergroup'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ── Legend ───────────────────────────────────────────────────
          Text(
            'About meeting data',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          Text(
            'Meeting data comes from each AA intergroup\'s own website via the '
            'TSML (Twelve Step Meeting List) open standard. Online meetings are '
            'provided by the Online Intergroup of AA (OIAA). Times and locations '
            'are maintained by each local intergroup — always verify with the '
            'source before attending.',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}

void _showAddIntergroupHelp(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline),
          SizedBox(width: 10),
          Text('Add Your Local Intergroup'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Meeting data uses the open TSML standard. Any AA intergroup '
              'website running the "12 Step Meeting List" WordPress plugin can '
              'be added as a source.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Steps to add your intergroup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Find your AA intergroup\'s website (e.g. ct-aa.org, '
              'aaemass.org, nyintergroup.org).\n\n'
              '2. Test if it has a TSML feed by opening this URL in your '
              'browser:\n'
              '   https://<intergroup-site>/wp-json/twelvesteplist/v2/meetings\n\n'
              '3. If it returns a list of meetings in JSON format, open '
              'meeting_sync_service.dart in the project and uncomment or add '
              'a TsmlAdapter block — instructions are in the file comments.',
              style: TextStyle(height: 1.6, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TsmlAdapter(\n'
                '  id:      \'tsml-aa-myregion\',\n'
                '  name:    \'AA — My Region\',\n'
                '  baseUrl: \'https://my-intergroup.org\',\n'
                '),',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _SourceCard extends StatelessWidget {
  final MeetingSourceAdapter adapter;
  final SourceSyncResult? result;
  const _SourceCard({required this.adapter, this.result});

  @override
  Widget build(BuildContext context) {
    final hasError = result?.hasError ?? false;
    final borderColor = hasError
        ? Colors.red.shade200
        : adapter.enabledByDefault
            ? Colors.green.shade200
            : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.shade50
            : adapter.enabledByDefault
                ? Colors.green.shade50
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fellowship badges
          Column(
            children: adapter.fellowships
                .map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _FellowshipBadge(fellowship: f),
                    ))
                .toList(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adapter.displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                if (!adapter.enabledByDefault)
                  Text(
                    'Scaffolded — awaiting verified API endpoint',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                  )
                else if (hasError)
                  Text(
                    _friendlyError(result!.errorMessage!),
                    style: const TextStyle(
                        color: Colors.red, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (result != null)
                  Text(
                    '+${result!.added} new · ${result!.updated} updated',
                    style: TextStyle(
                        color: Colors.green.shade700, fontSize: 11),
                  )
                else
                  Text(
                    'Active · pending first sync',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11),
                  ),
              ],
            ),
          ),
          Icon(
            hasError
                ? Icons.error_outline
                : adapter.enabledByDefault
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
            size: 18,
            color: hasError
                ? Colors.red
                : adapter.enabledByDefault
                    ? Colors.green.shade600
                    : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fellowship badge widget
// ─────────────────────────────────────────────────────────────────────────────

class _FellowshipBadge extends StatelessWidget {
  final String fellowship;
  final bool large;
  const _FellowshipBadge({required this.fellowship, this.large = false});

  @override
  Widget build(BuildContext context) {
    final style = _fellowshipStyle(fellowship);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 9 : 5, vertical: large ? 3 : 1),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: style.border),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Type chip
// ─────────────────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String code;
  final bool large;
  const _TypeChip({required this.code, this.large = false});

  @override
  Widget build(BuildContext context) {
    // kAllTypeCodes covers both AA (TSML) and NA type codes.
    final label = kAllTypeCodes[code] ?? code;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 10 : 6, vertical: large ? 4 : 2),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.indigo.shade700,
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  final bool isHybrid;
  final bool large;
  const _OnlineBadge({required this.isHybrid, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = isHybrid ? Colors.teal : Colors.purple;
    final label = isHybrid ? 'Hybrid' : 'Online';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 10 : 6, vertical: large ? 4 : 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// URL / launch helpers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _launchConference(
    BuildContext context, Meeting meeting) async {
  final url = meeting.conferenceUrl;
  if (url == null) return;

  // For Zoom: try the deep-link first; fall back to the web URL.
  if (meeting.onlinePlatform == 'zoom') {
    final webUri = Uri.tryParse(url);
    if (webUri != null) {
      final meetingId = webUri.pathSegments.lastWhere(
        (s) => RegExp(r'^\d{9,11}$').hasMatch(s),
        orElse: () => '',
      );
      final pwd = webUri.queryParameters['pwd'] ??
          webUri.queryParameters['password'];

      if (meetingId.isNotEmpty) {
        final deepLink = Uri.parse(
            'zoomus://zoom.us/join?confno=$meetingId${pwd != null ? '&pwd=$pwd' : ''}');
        if (await canLaunchUrl(deepLink)) {
          await launchUrl(deepLink);
          return;
        }
      }
    }
  }

  // Fallback: open in browser
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> _launchPhone(String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri.parse('tel:$digits');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

Future<void> _openMaps(Meeting meeting) async {
  // Prefer coordinate-based link for accuracy (geo: works on Android; iOS uses Apple Maps).
  if (meeting.latitude != null && meeting.longitude != null) {
    final lat = meeting.latitude!;
    final lng = meeting.longitude!;
    final Uri coordUri = Platform.isIOS
        ? appleMapsUriForCoordinates(
            latitude: lat,
            longitude: lng,
            placeName: meeting.name,
          )
        : Uri.parse(
            'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(meeting.name)})',
          );
    if (await canLaunchUrl(coordUri)) {
      await launchUrl(coordUri, mode: LaunchMode.externalApplication);
      return;
    }
  }
  final query =
      meeting.address ?? '${meeting.locationName}, ${meeting.city}';
  final Uri fallbackUri = Platform.isIOS
      ? appleMapsUriForQuery(query)
      : Uri.parse(
          'https://maps.google.com/?q=${Uri.encodeComponent(query)}',
        );
  if (await canLaunchUrl(fallbackUri)) {
    await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility functions
// ─────────────────────────────────────────────────────────────────────────────

String _formatTime(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  final ampm = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return m == 0 ? '$h12 $ampm' : '$h12:${m.toString().padLeft(2, '0')} $ampm';
}
