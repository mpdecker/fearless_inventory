import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../data/repositories/step12_repository.dart';
import '../../data/repositories/service_commitments_repository.dart';
import '../../data/repositories/sponsee_repository.dart';
import '../meetings/services/meeting_calendar_service.dart';
import 'sponsee_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Event type metadata
// ─────────────────────────────────────────────────────────────────────────────

enum Step12EventType {
  general('general', 'General', Color(0xFF607D8B)),
  meeting('meeting', 'Meeting', Color(0xFFE65100)),
  service('service', 'Service', Color(0xFF00695C)),
  sponsee('sponsee', 'Sponsee', Color(0xFF6A1B9A));

  final String value;
  final String label;
  final Color color;
  const Step12EventType(this.value, this.label, this.color);

  static Step12EventType fromString(String s) =>
      values.firstWhere((e) => e.value == s, orElse: () => general);

  IconData get icon {
    switch (this) {
      case Step12EventType.meeting:
        return Icons.groups_outlined;
      case Step12EventType.service:
        return Icons.volunteer_activism_outlined;
      case Step12EventType.sponsee:
        return Icons.person_outlined;
      case Step12EventType.general:
        return Icons.event_outlined;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final _allEventsProvider = StreamProvider<List<StepTwelveEvent>>(
  (ref) => ref.watch(step12RepositoryProvider).watchAll(),
);

final _allSponseesProvider = StreamProvider<List<Sponsee>>(
  (ref) => ref.watch(sponseeRepositoryProvider).watchAll(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Root screen — tabs: Calendar | Sponsees | Service
// ─────────────────────────────────────────────────────────────────────────────

class Step12Screen extends ConsumerStatefulWidget {
  const Step12Screen({super.key});

  @override
  ConsumerState<Step12Screen> createState() => _Step12ScreenState();

  static void _openAddEvent(BuildContext context, DateTime initialDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddEditEventSheet(initialDate: initialDate),
    );
  }

  /// Called from _CalendarTab and _Step12ScreenState FAB.
  static void openAddEventForDay(BuildContext context, DateTime day) =>
      _openAddEvent(context, day);
}

class _Step12ScreenState extends ConsumerState<Step12Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 12'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Calendar'),
            Tab(icon: Icon(Icons.people_outline), text: 'Sponsees'),
            Tab(icon: Icon(Icons.volunteer_activism_outlined), text: 'Service'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CalendarTab(),
          _SponseeTab(),
          _ServiceTab(),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget? _buildFab(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () => Step12Screen._openAddEvent(context, DateTime.now()),
          icon: const Icon(Icons.add),
          label: const Text('Add Event'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _SponseeTab.openAddSponsee(context),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add Sponsee'),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
        );
      case 2:
        final subTab = ref.watch(serviceSubTabProvider);
        if (subTab == 1) {
          return FloatingActionButton.extended(
            onPressed: () => _ServiceTab.openLogCall(context),
            icon: const Icon(Icons.phone_in_talk_outlined),
            label: const Text('Log Call'),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          );
        }
        return FloatingActionButton.extended(
          onPressed: () => _ServiceTab.openAddCommitment(context),
          icon: const Icon(Icons.add_task_outlined),
          label: const Text('Add Commitment'),
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calendar tab
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarTab extends HookConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(_allEventsProvider);
    final focusedDay = useState(DateTime.now());
    final selectedDay = useState<DateTime>(DateTime.now());
    final calendarFormat = useState(CalendarFormat.month);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (events) {
        // Build a lookup map: day key → list of events
        final eventMap = <DateTime, List<StepTwelveEvent>>{};
        for (final e in events) {
          final key = _dayKey(e.startTime);
          (eventMap[key] ??= []).add(e);
        }

        List<StepTwelveEvent> eventsForDay(DateTime day) =>
            eventMap[_dayKey(day)] ?? [];

        final selectedEvents = eventsForDay(selectedDay.value);

        return Column(
          children: [
            // ── Calendar ──────────────────────────────────────────────
            TableCalendar<StepTwelveEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: focusedDay.value,
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay.value, day),
              calendarFormat: calendarFormat.value,
              eventLoader: eventsForDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13),
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                // Colour-coded dots per event type
                markerBuilder: (ctx, day, dayEvents) {
                  if (dayEvents.isEmpty) return const SizedBox.shrink();
                  final shown = dayEvents.take(4).toList();
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: shown.map((e) {
                        final type = Step12EventType.fromString(e.eventType);
                        return Container(
                          width: 6,
                          height: 6,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: type.color,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              onDaySelected: (selected, focused) {
                selectedDay.value = selected;
                focusedDay.value = focused;
              },
              onFormatChanged: (fmt) => calendarFormat.value = fmt,
              onPageChanged: (focused) => focusedDay.value = focused,
            ),

            const Divider(height: 1),

            // ── Selected day header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(selectedDay.value),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Step12Screen.openAddEventForDay(
                        context, selectedDay.value),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),

            // ── Events for selected day ────────────────────────────────
            Expanded(
              child: selectedEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No events scheduled',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                      itemCount: selectedEvents.length,
                      itemBuilder: (_, i) =>
                          _EventTile(event: selectedEvents[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Normalise a DateTime to midnight for use as a map key.
  static DateTime _dayKey(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}

// ─────────────────────────────────────────────────────────────────────────────
// Single event tile
// ─────────────────────────────────────────────────────────────────────────────

class _EventTile extends ConsumerWidget {
  final StepTwelveEvent event;
  const _EventTile({required this.event});

  static final _timeFmt = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = Step12EventType.fromString(event.eventType);
    final hasTime = event.startTime.hour != 0 || event.startTime.minute != 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: type.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(type.icon, color: type.color, size: 20),
        ),
        title: Text(event.title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTime)
              Text(
                _buildTimeRange(),
                style: TextStyle(
                    color: type.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            if (event.location != null && event.location!.isNotEmpty)
              Text(
                '📍 ${event.location}',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            if (event.description != null &&
                event.description!.isNotEmpty)
              Text(
                event.description!,
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: type.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type.label,
                style: TextStyle(
                    color: type.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (val) {
                if (val == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24))),
                    builder: (_) =>
                        _AddEditEventSheet(
                          initialDate: event.startTime,
                          existingEvent: event,
                        ),
                  );
                } else if (val == 'delete') {
                  ref.read(step12RepositoryProvider).delete(event.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildTimeRange() {
    final start = _timeFmt.format(event.startTime);
    if (event.endTime == null) return start;
    final end = _timeFmt.format(event.endTime!);
    return '$start – $end';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit event bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddEditEventSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final StepTwelveEvent? existingEvent;

  const _AddEditEventSheet({
    required this.initialDate,
    this.existingEvent,
  });

  @override
  ConsumerState<_AddEditEventSheet> createState() =>
      _AddEditEventSheetState();
}

class _AddEditEventSheetState extends ConsumerState<_AddEditEventSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;

  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late Step12EventType _eventType;

  bool get _isEditing => widget.existingEvent != null;

  static final _dateFmt = DateFormat('EEE, MMM d, yyyy');
  static final _timeFmt = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _selectedDate = e?.startTime ?? widget.initialDate;
    _eventType = e != null
        ? Step12EventType.fromString(e.eventType)
        : Step12EventType.general;

    if (e != null) {
      final st = e.startTime;
      if (st.hour != 0 || st.minute != 0) {
        _startTime = TimeOfDay(hour: st.hour, minute: st.minute);
      }
      if (e.endTime != null) {
        final et = e.endTime!;
        _endTime = TimeOfDay(hour: et.hour, minute: et.minute);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  DateTime _buildDateTime(DateTime date, TimeOfDay? time) {
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            // ── Drag handle ─────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ───────────────────────────────────────────────
            Text(
              _isEditing ? 'Edit Event' : 'New Event',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Event title ─────────────────────────────────────────
            TextField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. Home Group, Sponsor Call',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Event type ──────────────────────────────────────────
            const Text('Type',
                style:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Step12EventType.values.map((t) {
                final selected = _eventType == t;
                return FilterChip(
                  avatar: Icon(t.icon,
                      size: 16,
                      color: selected ? Colors.white : t.color),
                  label: Text(t.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _eventType = t),
                  selectedColor: t.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w600 : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Date ────────────────────────────────────────────────
            const Text('Date',
                style:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_dateFmt.format(_selectedDate)),
            ),
            const SizedBox(height: 16),

            // ── Time ────────────────────────────────────────────────
            const Text('Time (optional)',
                style:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Start time
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            _startTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => _startTime = picked);
                      }
                    },
                    icon: const Icon(Icons.schedule_outlined, size: 18),
                    label: Text(_startTime != null
                        ? _timeFmt.format(_buildDateTime(
                            _selectedDate, _startTime))
                        : 'Start'),
                  ),
                ),
                const SizedBox(width: 8),
                // End time
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _startTime == null
                        ? null
                        : () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _endTime ??
                                  TimeOfDay(
                                      hour: (_startTime!.hour + 1)
                                          .clamp(0, 23),
                                      minute: _startTime!.minute),
                            );
                            if (picked != null) {
                              setState(() => _endTime = picked);
                            }
                          },
                    icon: const Icon(Icons.schedule_outlined, size: 18),
                    label: Text(_endTime != null
                        ? _timeFmt.format(
                            _buildDateTime(_selectedDate, _endTime))
                        : 'End'),
                  ),
                ),
                // Clear time button
                if (_startTime != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Clear time',
                    onPressed: () => setState(() {
                      _startTime = null;
                      _endTime = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Location ────────────────────────────────────────────
            TextField(
              controller: _locationCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g. St. Mary\'s Church, Zoom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description ─────────────────────────────────────────
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            // ── Save ────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isEditing ? 'Update Event' : 'Save Event',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final startDt = _buildDateTime(_selectedDate, _startTime);
    final endDt = _endTime != null
        ? _buildDateTime(_selectedDate, _endTime)
        : null;

    final repo = ref.read(step12RepositoryProvider);

    if (_isEditing) {
      await repo.update(widget.existingEvent!.copyWith(
        title: title,
        description: Value(_descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim()),
        location: Value(_locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim()),
        startTime: startDt,
        endTime: Value(endDt),
        eventType: _eventType.value,
      ));
    } else {
      await repo.insert(StepTwelveEventsCompanion(
        title: Value(title),
        description: Value(_descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim()),
        location: Value(_locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim()),
        startTime: Value(startDt),
        endTime: Value(endDt),
        eventType: Value(_eventType.value),
      ));
    }

    if (mounted) Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsee tab — stub
// ─────────────────────────────────────────────────────────────────────────────

class _SponseeTab extends HookConsumerWidget {
  const _SponseeTab();

  static void openAddSponsee(BuildContext context, [Sponsee? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddSponseeSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sponseesAsync = ref.watch(_allSponseesProvider);

    return sponseesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sponsees) {
        if (sponsees.isEmpty) {
          return _SponseeEmptyState(
            onAdd: () => openAddSponsee(context),
          );
        }

        final active = sponsees.where((s) => s.isActive).toList();
        final inactive = sponsees.where((s) => !s.isActive).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          children: [
            if (active.isNotEmpty) ...[
              _SectionHeader(
                  title: 'Active Sponsees (${active.length})',
                  color: Colors.purple.shade700),
              for (final s in active) _SponseeCard(sponsee: s),
            ],
            if (inactive.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionHeader(
                  title: 'Past Sponsees (${inactive.length})',
                  color: Colors.grey.shade600),
              for (final s in inactive) _SponseeCard(sponsee: s),
            ],
          ],
        );
      },
    );
  }
}

// ── Sponsee empty state ───────────────────────────────────────────────────────

class _SponseeEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _SponseeEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 72, color: Colors.purple.shade200),
            const SizedBox(height: 20),
            const Text('Sponsee Tracking',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Track your sponsees\' contact info, step progress, '
              'sobriety milestones, and check-in history — all in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Your First Sponsee'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sponsee card ──────────────────────────────────────────────────────────────

class _SponseeCard extends ConsumerWidget {
  final Sponsee sponsee;
  const _SponseeCard({required this.sponsee});

  static final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = sponsee.sobrietyDate != null
        ? DateTime.now()
            .difference(sponsee.sobrietyDate!)
            .inDays
        : null;
    final step = sponsee.currentStep;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: sponsee.isActive
          ? Colors.purple.shade50
          : Colors.grey.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SponseeDetailScreen(sponseeId: sponsee.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: sponsee.isActive
                    ? Colors.purple.shade200
                    : Colors.grey.shade300,
                child: Text(
                  sponsee.name.isNotEmpty
                      ? sponsee.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: sponsee.isActive
                        ? Colors.purple.shade900
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsee.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (step != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Step $step',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (days != null)
                          Text(
                            '$days days sober',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                          ),
                        if (days == null && sponsee.startedSponsoringDate != null)
                          Text(
                            'Since ${_dateFmt.format(sponsee.startedSponsoringDate!)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.purple.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit sponsee sheet
// ─────────────────────────────────────────────────────────────────────────────

class AddSponseeSheet extends ConsumerStatefulWidget {
  final Sponsee? existing;
  const AddSponseeSheet({this.existing});

  @override
  ConsumerState<AddSponseeSheet> createState() => _AddSponseeSheetState();
}

class _AddSponseeSheetState extends ConsumerState<AddSponseeSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _sobrietyDate;
  DateTime? _startedSponsoringDate;
  int? _currentStep;

  static final _dateFmt = DateFormat('MMM d, yyyy');

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _sobrietyDate = e?.sobrietyDate;
    _startedSponsoringDate = e?.startedSponsoringDate ?? DateTime.now();
    _currentStep = e?.currentStep;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context,
      {required DateTime? initial,
      required void Function(DateTime) onPicked,
      bool futureOk = false}) async {
    final now = DateTime.now();
    final last = futureOk ? DateTime(now.year + 10) : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(1950),
      lastDate: last,
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(sponseeRepositoryProvider);
    if (_isEditing) {
      await repo.updateSponsee(widget.existing!.copyWith(
        name: name,
        phone: Value(_phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim()),
        email: Value(_emailCtrl.text.trim().isEmpty
            ? null
            : _emailCtrl.text.trim()),
        sobrietyDate: Value(_sobrietyDate),
        startedSponsoringDate: Value(_startedSponsoringDate),
        currentStep: Value(_currentStep),
        notes: Value(_notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim()),
      ));
    } else {
      await repo.insertSponsee(SponseesCompanion(
        name: Value(name),
        phone: Value(_phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim()),
        email: Value(_emailCtrl.text.trim().isEmpty
            ? null
            : _emailCtrl.text.trim()),
        sobrietyDate: Value(_sobrietyDate),
        startedSponsoringDate: Value(_startedSponsoringDate),
        currentStep: Value(_currentStep),
        notes: Value(_notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim()),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _DragHandle(),
            Text(
              _isEditing ? 'Edit Sponsee' : 'Add Sponsee',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Name
            _FormLabel('Name *'),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'First name (or full name)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            _FormLabel('Phone'),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            _FormLabel('Email'),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Sobriety date
            _FormLabel('Their Sobriety Date'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today_outlined,
                  color: Colors.purple.shade600, size: 22),
              title: Text(
                _sobrietyDate != null
                    ? _dateFmt.format(_sobrietyDate!)
                    : 'Not set',
                style: TextStyle(
                    color: _sobrietyDate != null
                        ? Colors.black87
                        : Colors.grey.shade500),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_sobrietyDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _sobrietyDate = null),
                    ),
                  TextButton(
                    onPressed: () => _pickDate(context,
                        initial: _sobrietyDate,
                        onPicked: (d) => _sobrietyDate = d),
                    child: Text(_sobrietyDate != null ? 'Change' : 'Set'),
                  ),
                ],
              ),
            ),

            // Started sponsoring date
            _FormLabel('Sponsoring Since'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.handshake_outlined,
                  color: Colors.purple.shade600, size: 22),
              title: Text(
                _startedSponsoringDate != null
                    ? _dateFmt.format(_startedSponsoringDate!)
                    : 'Not set',
                style: TextStyle(
                    color: _startedSponsoringDate != null
                        ? Colors.black87
                        : Colors.grey.shade500),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_startedSponsoringDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () =>
                          setState(() => _startedSponsoringDate = null),
                    ),
                  TextButton(
                    onPressed: () => _pickDate(context,
                        initial: _startedSponsoringDate,
                        futureOk: true,
                        onPicked: (d) => _startedSponsoringDate = d),
                    child: Text(
                        _startedSponsoringDate != null ? 'Change' : 'Set'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Current step
            _FormLabel('Current Step'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (int s = 1; s <= 12; s++)
                  ChoiceChip(
                    label: Text('$s'),
                    selected: _currentStep == s,
                    onSelected: (_) =>
                        setState(() => _currentStep = _currentStep == s ? null : s),
                    selectedColor: Colors.purple.shade200,
                    labelStyle: TextStyle(
                      fontWeight: _currentStep == s
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            _FormLabel('Notes'),
            TextField(
              controller: _notesCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Optional notes about this sponsee',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                  _isEditing ? 'Save Changes' : 'Add Sponsee',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Service tab — sub-tab state provider
// ─────────────────────────────────────────────────────────────────────────────

/// 0 = Commitments view, 1 = 12th Step Calls view.
/// Exposed as a provider so the parent FAB can react to it.
final serviceSubTabProvider = StateProvider<int>((ref) => 0);

// ─────────────────────────────────────────────────────────────────────────────
// Service tab — root
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceTab extends HookConsumerWidget {
  const _ServiceTab();

  static void openAddCommitment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddCommitmentSheet(),
    );
  }

  static void openLogCall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const AddStepCallSheet(isScheduled: false),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subTab = ref.watch(serviceSubTabProvider);

    return Column(
      children: [
        // ── Sub-tab selector ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Commitments'),
                icon: Icon(Icons.volunteer_activism_outlined),
              ),
              ButtonSegment(
                value: 1,
                label: Text('12th Step Calls'),
                icon: Icon(Icons.phone_in_talk_outlined),
              ),
            ],
            selected: {subTab},
            onSelectionChanged: (s) =>
                ref.read(serviceSubTabProvider.notifier).state = s.first,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // ── Content ─────────────────────────────────────────────────────
        Expanded(
          child: subTab == 0
              ? const _CommitmentsView()
              : const _StepCallsView(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Commitment type metadata
// ─────────────────────────────────────────────────────────────────────────────

enum ServiceCommitmentType {
  position('position', 'Service Position', Color(0xFF00695C), Icons.stars_outlined),
  speaking('speaking', 'Speaking', Color(0xFF1565C0), Icons.record_voice_over_outlined),
  general('general', 'General Service', Color(0xFF6A1B9A), Icons.volunteer_activism_outlined);

  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const ServiceCommitmentType(this.value, this.label, this.color, this.icon);

  static ServiceCommitmentType fromString(String s) =>
      values.firstWhere((e) => e.value == s, orElse: () => general);
}

// Common service position title suggestions shown in the add sheet.
const _kPositionSuggestions = [
  'GSR',
  'Alternate GSR',
  'Group Secretary',
  'Group Treasurer',
  'Chairperson',
  'Literature Chair',
  'Coffee Maker',
  'Greeter',
  'Speaker Chair',
  'H&I Representative',
  'Corrections Representative',
  'Intergroup Representative',
  'District Committee Member',
  'Phone Line Volunteer',
];

// ─────────────────────────────────────────────────────────────────────────────
// Commitments view
// ─────────────────────────────────────────────────────────────────────────────

final _activeCommitmentsProvider = StreamProvider<List<ServiceCommitment>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchActive(),
);
final _historyCommitmentsProvider = StreamProvider<List<ServiceCommitment>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchHistory(),
);

class _CommitmentsView extends HookConsumerWidget {
  const _CommitmentsView();

  static final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(_activeCommitmentsProvider);
    final historyAsync = ref.watch(_historyCommitmentsProvider);
    final showHistory = useState(false);

    return activeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (active) {
        if (active.isEmpty && !showHistory.value) {
          return _ServiceEmptyState(
            onAdd: () => _ServiceTab.openAddCommitment(context),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
          children: [
            // ── Stats row ────────────────────────────────────────────
            if (active.isNotEmpty) _ServiceStatsRow(commitments: active),

            // ── Active section ───────────────────────────────────────
            if (active.isNotEmpty) ...[
              _SectionHeader(
                title: 'Active (${active.length})',
                color: Colors.teal.shade700,
              ),
              for (final c in active) _CommitmentCard(commitment: c),
            ],

            // ── History toggle ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton.icon(
                onPressed: () => showHistory.value = !showHistory.value,
                icon: Icon(
                    showHistory.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18),
                label: Text(showHistory.value
                    ? 'Hide History'
                    : 'Show Past Commitments'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600),
              ),
            ),

            // ── History section ──────────────────────────────────────
            if (showHistory.value)
              historyAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (history) {
                  if (history.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No past commitments yet.',
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                          title: 'Past (${history.length})',
                          color: Colors.grey.shade600),
                      for (final c in history)
                        _CommitmentCard(commitment: c, dimmed: true),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceStatsRow extends StatelessWidget {
  final List<ServiceCommitment> commitments;
  const _ServiceStatsRow({required this.commitments});

  @override
  Widget build(BuildContext context) {
    final positions =
        commitments.where((c) => c.type == 'position').length;
    final speaking =
        commitments.where((c) => c.type == 'speaking').length;
    final general =
        commitments.where((c) => c.type == 'general').length;
    final withReminders =
        commitments.where((c) => c.reminderEnabled).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      child: Row(
        children: [
          _StatPill(label: 'Positions', count: positions,
              color: ServiceCommitmentType.position.color),
          const SizedBox(width: 8),
          _StatPill(label: 'Speaking', count: speaking,
              color: ServiceCommitmentType.speaking.color),
          const SizedBox(width: 8),
          _StatPill(label: 'General', count: general,
              color: ServiceCommitmentType.general.color),
          const SizedBox(width: 8),
          if (withReminders > 0)
            _StatPill(label: 'Reminders', count: withReminders,
                color: Colors.orange.shade700,
                icon: Icons.notifications_outlined),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData? icon;
  const _StatPill(
      {required this.label,
      required this.count,
      required this.color,
      this.icon});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            '$count $label',
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Commitment card
// ─────────────────────────────────────────────────────────────────────────────

class _CommitmentCard extends ConsumerWidget {
  final ServiceCommitment commitment;
  final bool dimmed;
  const _CommitmentCard(
      {required this.commitment, this.dimmed = false});

  static final _dateFmt = DateFormat('MMM d, yyyy');
  static final _timeFmt = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type =
        ServiceCommitmentType.fromString(commitment.type);
    final opacity = dimmed ? 0.55 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: dimmed
                  ? Colors.grey.shade200
                  : type.color.withOpacity(0.25)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetail(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(type.icon, color: type.color, size: 20),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              commitment.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                          ),
                          // Type chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: type.color.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type.label,
                              style: TextStyle(
                                  color: type.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),

                      // Organization
                      if (commitment.organization != null &&
                          commitment.organization!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          commitment.organization!,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],

                      // Date range
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _buildDateRange(),
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                          if (commitment.isRecurring) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.repeat,
                                size: 12, color: Colors.teal.shade400),
                            const SizedBox(width: 3),
                            Text(
                              _buildRecurringLabel(),
                              style: TextStyle(
                                  color: Colors.teal.shade600,
                                  fontSize: 12),
                            ),
                          ],
                          if (commitment.reminderEnabled) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.notifications_outlined,
                                size: 12,
                                color: Colors.orange.shade400),
                          ],
                        ],
                      ),

                      // Notes preview
                      if (commitment.notes != null &&
                          commitment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          commitment.notes!,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      size: 18, color: Colors.grey.shade400),
                  onSelected: (val) => _onMenuAction(context, ref, val),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: const Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: commitment.isActive
                          ? 'complete'
                          : 'reactivate',
                      child: Row(
                        children: [
                          Icon(
                            commitment.isActive
                                ? Icons.check_circle_outline
                                : Icons.replay_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(commitment.isActive
                              ? 'Mark Complete'
                              : 'Reactivate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildDateRange() {
    final start = _dateFmt.format(commitment.startDate);
    if (commitment.endDate == null) return '$start – Ongoing';
    return '$start – ${_dateFmt.format(commitment.endDate!)}';
  }

  String _buildRecurringLabel() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final day = commitment.recurringWeekday != null
        ? days[commitment.recurringWeekday!.clamp(0, 6)]
        : '';
    final time = commitment.recurringTime ?? '';
    if (day.isEmpty && time.isEmpty) return 'Weekly';
    if (time.isEmpty) return 'Every $day';
    // Format "HH:mm" → human-readable
    final parts = time.split(':');
    if (parts.length < 2) return 'Every $day';
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final ampm = h < 12 ? 'AM' : 'PM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    final timeStr =
        m == 0 ? '$h12 $ampm' : '$h12:${m.toString().padLeft(2, '0')} $ampm';
    return 'Every $day $timeStr';
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddCommitmentSheet(existing: commitment),
    );
  }

  void _onMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(serviceCommitmentsRepositoryProvider);
    switch (action) {
      case 'edit':
        _showDetail(context, ref);
        break;
      case 'complete':
        await repo.setActive(commitment.id, value: false);
        break;
      case 'reactivate':
        await repo.setActive(commitment.id, value: true);
        break;
      case 'delete':
        final ok = await _confirmDelete(context);
        if (ok) await repo.deleteCommitment(commitment.id);
        break;
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Commitment?'),
            content: Text(
                'Remove "${commitment.title}"? This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 12th step calls view
// ─────────────────────────────────────────────────────────────────────────────

enum StepCallType {
  call('call', 'Phone Call', Color(0xFF0277BD), Icons.phone_in_talk_outlined),
  visit('visit', 'In-Person Visit', Color(0xFF2E7D32), Icons.home_outlined),
  sponsorship('sponsorship', 'Sponsee', Color(0xFF6A1B9A), Icons.person_outlined),
  general('general', 'General', Color(0xFF607D8B), Icons.volunteer_activism_outlined);

  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const StepCallType(this.value, this.label, this.color, this.icon);

  static StepCallType fromString(String s) =>
      values.firstWhere((e) => e.value == s, orElse: () => general);
}

final _stepCallsProvider = StreamProvider<List<TwelfthStepCall>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchCalls(),
);
final _scheduledCallsProvider = StreamProvider<List<TwelfthStepCall>>(
  (ref) =>
      ref.watch(serviceCommitmentsRepositoryProvider).watchScheduledCalls(),
);
final _pastCallsProvider = StreamProvider<List<TwelfthStepCall>>(
  (ref) => ref.watch(serviceCommitmentsRepositoryProvider).watchPastCalls(),
);
final _callsThisMonthProvider = StreamProvider<int>(
  (ref) =>
      ref.watch(serviceCommitmentsRepositoryProvider).watchCallsThisMonth(),
);

class _StepCallsView extends HookConsumerWidget {
  const _StepCallsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledAsync = ref.watch(_scheduledCallsProvider);
    final pastAsync = ref.watch(_pastCallsProvider);
    final monthCountAsync = ref.watch(_callsThisMonthProvider);
    final allAsync = ref.watch(_stepCallsProvider);

    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allCalls) {
        if (allCalls.isEmpty) {
          return _StepCallsEmptyState(
            onLog: () => _ServiceTab.openLogCall(context),
          );
        }

        final scheduled = scheduledAsync.valueOrNull ?? [];
        final past = pastAsync.valueOrNull ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
          children: [
            // ── Upcoming planned calls ────────────────────────────
            if (scheduled.isNotEmpty) ...[
              _SectionHeader(
                title: 'Upcoming Planned (${scheduled.length})',
                color: Colors.purple.shade700,
              ),
              for (final c in scheduled) _StepCallCard(call: c),
              const SizedBox(height: 8),
            ],

            // ── Month counter ─────────────────────────────────────
            monthCountAsync.whenData((n) => _MonthCallsBanner(count: n))
                    .valueOrNull ??
                const SizedBox.shrink(),

            const SizedBox(height: 8),
            if (past.isNotEmpty) ...[
              _SectionHeader(
                title: 'History (${past.length})',
                color: Colors.blue.shade700,
              ),
              for (final c in past) _StepCallCard(call: c),
            ],
          ],
        );
      },
    );
  }
}

class _MonthCallsBanner extends StatelessWidget {
  final int count;
  const _MonthCallsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM').format(DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_outline,
              size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              count == 0
                  ? 'No 12th-step work logged in $month yet'
                  : '$count 12th-step interaction${count == 1 ? '' : 's'} in $month',
              style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCallCard extends ConsumerWidget {
  final TwelfthStepCall call;
  const _StepCallCard({required this.call});

  static final _dtFmt = DateFormat('EEE, MMM d · h:mm a');

  bool get _isScheduled =>
      call.scheduledAt != null &&
      call.scheduledAt!.isAfter(DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = StepCallType.fromString(call.callType);
    final displayDt = _isScheduled ? call.scheduledAt! : call.occurredAt;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _isScheduled ? Colors.purple.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isScheduled
              ? Colors.purple.shade200
              : type.color.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (_isScheduled ? Colors.purple : type.color)
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                _isScheduled ? Icons.event_outlined : type.icon,
                color: _isScheduled ? Colors.purple.shade700 : type.color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          call.person != null && call.person!.isNotEmpty
                              ? call.person!
                              : type.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      if (_isScheduled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Scheduled',
                              style: TextStyle(
                                  color: Colors.purple.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        )
                      else if (call.person != null && call.person!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: type.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(type.label,
                              style: TextStyle(
                                  color: type.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dtFmt.format(displayDt),
                    style: TextStyle(
                        color: _isScheduled
                            ? Colors.purple.shade700
                            : Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: _isScheduled ? FontWeight.w500 : null),
                  ),
                  if (call.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(call.description,
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  if (!_isScheduled &&
                      call.outcome != null &&
                      call.outcome!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 12, color: Colors.green.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(call.outcome!,
                              style: TextStyle(
                                  color: Colors.green.shade700, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  size: 18, color: Colors.grey.shade400),
              onSelected: (val) async {
                if (val == 'complete') {
                  await ref
                      .read(serviceCommitmentsRepositoryProvider)
                      .completeScheduledCall(call.id);
                } else if (val == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24))),
                    builder: (_) => AddStepCallSheet(existing: call),
                  );
                } else if (val == 'delete') {
                  await ref
                      .read(serviceCommitmentsRepositoryProvider)
                      .deleteCall(call.id);
                }
              },
              itemBuilder: (_) => [
                if (_isScheduled)
                  const PopupMenuItem(
                      value: 'complete',
                      child: Row(children: [
                        Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Mark Complete',
                            style: TextStyle(color: Colors.green)),
                      ])),
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit commitment sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddCommitmentSheet extends ConsumerStatefulWidget {
  final ServiceCommitment? existing;
  const _AddCommitmentSheet({this.existing});

  @override
  ConsumerState<_AddCommitmentSheet> createState() =>
      _AddCommitmentSheetState();
}

class _AddCommitmentSheetState
    extends ConsumerState<_AddCommitmentSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _orgCtrl;
  late final TextEditingController _notesCtrl;

  late ServiceCommitmentType _type;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isRecurring;
  int? _recurringWeekday;
  TimeOfDay? _recurringTime;
  late bool _reminderEnabled;
  int _reminderMinutes = 30;

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _reminderOptions = {
    15: '15 min before',
    30: '30 min before',
    60: '1 hour before',
    120: '2 hours before',
  };
  static final _dateFmt = DateFormat('EEE, MMM d, yyyy');

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _orgCtrl = TextEditingController(text: e?.organization ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _type = e != null
        ? ServiceCommitmentType.fromString(e.type)
        : ServiceCommitmentType.position;
    _startDate = e?.startDate ?? DateTime.now();
    _endDate = e?.endDate;
    _isRecurring = e?.isRecurring ?? false;
    _recurringWeekday = e?.recurringWeekday;
    if (e?.recurringTime != null) {
      final parts = e!.recurringTime!.split(':');
      if (parts.length == 2) {
        _recurringTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0);
      }
    }
    _reminderEnabled = e?.reminderEnabled ?? false;
    _reminderMinutes = e?.reminderMinutesBefore ?? 30;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _orgCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _DragHandle(),
            Text(
              _isEditing ? 'Edit Commitment' : 'New Service Commitment',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── Type ──────────────────────────────────────────────────
            _FormLabel('Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ServiceCommitmentType.values.map((t) {
                final sel = _type == t;
                return FilterChip(
                  avatar: Icon(t.icon,
                      size: 15, color: sel ? Colors.white : t.color),
                  label: Text(t.label),
                  selected: sel,
                  onSelected: (_) => setState(() => _type = t),
                  selectedColor: t.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : null,
                      fontWeight:
                          sel ? FontWeight.w600 : null,
                      fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Title ─────────────────────────────────────────────────
            TextField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g. GSR, Coffee Maker, Speaker',
                border: OutlineInputBorder(),
              ),
            ),

            // Suggestion chips for position type
            if (_type == ServiceCommitmentType.position) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _kPositionSuggestions.map((s) {
                  return ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _titleCtrl.text = s;
                      _titleCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: s.length));
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // ── Organization ──────────────────────────────────────────
            TextField(
              controller: _orgCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Group / Organization (optional)',
                hintText: 'e.g. Monday Morning Group, District 12',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.groups_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // ── Start date ────────────────────────────────────────────
            _FormLabel('Start Date'),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (d != null) setState(() => _startDate = d);
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_dateFmt.format(_startDate)),
            ),
            const SizedBox(height: 12),

            // ── End date ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _FormLabel(_endDate == null
                      ? 'End Date — Ongoing'
                      : 'End: ${_dateFmt.format(_endDate!)}'),
                ),
                if (_endDate != null)
                  TextButton(
                    onPressed: () => setState(() => _endDate = null),
                    child: const Text('Clear'),
                  ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _endDate ??
                          _startDate.add(const Duration(days: 90)),
                      firstDate: _startDate,
                      lastDate: DateTime(2035),
                    );
                    if (d != null) setState(() => _endDate = d);
                  },
                  icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                  label: const Text('Set'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Recurring ─────────────────────────────────────────────
            SwitchListTile(
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              title: const Text('Recurring',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Repeats on the same day each week'),
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.teal.shade600,
            ),

            if (_isRecurring) ...[
              const SizedBox(height: 8),
              _FormLabel('Day of week'),
              Wrap(
                spacing: 6,
                children: List.generate(7, (i) {
                  final sel = _recurringWeekday == i;
                  return ChoiceChip(
                    label: Text(_weekdays[i]),
                    selected: sel,
                    onSelected: (_) =>
                        setState(() => _recurringWeekday = i),
                    visualDensity: VisualDensity.compact,
                    labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            sel ? FontWeight.bold : FontWeight.normal),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _recurringTime != null
                        ? 'Time: ${_recurringTime!.format(context)}'
                        : 'No time set (optional)',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime:
                            _recurringTime ?? TimeOfDay.now(),
                      );
                      if (t != null) setState(() => _recurringTime = t);
                    },
                    child: const Text('Set Time'),
                  ),
                  if (_recurringTime != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () =>
                          setState(() => _recurringTime = null),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 16),

            // ── Reminder ──────────────────────────────────────────────
            SwitchListTile(
              value: _reminderEnabled,
              onChanged: _isRecurring && _recurringWeekday != null
                  ? (v) => setState(() => _reminderEnabled = v)
                  : null,
              title: const Text('Reminder',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(_isRecurring && _recurringWeekday != null
                  ? 'Weekly notification before this commitment'
                  : 'Set a recurring schedule first'),
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.orange.shade600,
            ),

            if (_reminderEnabled && _isRecurring) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _reminderMinutes,
                decoration: const InputDecoration(
                  labelText: 'Notify me',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notifications_outlined),
                ),
                items: _reminderOptions.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _reminderMinutes = v);
                },
              ),
            ],
            const SizedBox(height: 16),

            // ── Notes ─────────────────────────────────────────────────
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            // ── Save ──────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                  _isEditing
                      ? 'Update Commitment'
                      : 'Save Commitment',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildRecurringTime() {
    if (_recurringTime == null) return null;
    return '${_recurringTime!.hour.toString().padLeft(2, '0')}:'
        '${_recurringTime!.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(serviceCommitmentsRepositoryProvider);

    final companion = ServiceCommitmentsCompanion(
      type: Value(_type.value),
      title: Value(title),
      organization: Value(
          _orgCtrl.text.trim().isEmpty ? null : _orgCtrl.text.trim()),
      startDate: Value(_startDate),
      endDate: Value(_endDate),
      isRecurring: Value(_isRecurring),
      recurringWeekday: Value(_isRecurring ? _recurringWeekday : null),
      recurringTime: Value(_isRecurring ? _buildRecurringTime() : null),
      reminderEnabled:
          Value(_reminderEnabled && _isRecurring),
      reminderMinutesBefore:
          Value(_reminderEnabled && _isRecurring ? _reminderMinutes : null),
      notes: Value(
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
    );

    if (_isEditing) {
      await repo.updateCommitment(widget.existing!.copyWith(
        type: _type.value,
        title: title,
        organization: Value(_orgCtrl.text.trim().isEmpty
            ? null
            : _orgCtrl.text.trim()),
        startDate: _startDate,
        endDate: Value(_endDate),
        isRecurring: _isRecurring,
        recurringWeekday:
            Value(_isRecurring ? _recurringWeekday : null),
        recurringTime:
            Value(_isRecurring ? _buildRecurringTime() : null),
        reminderEnabled: _reminderEnabled && _isRecurring,
        reminderMinutesBefore: Value(
            _reminderEnabled && _isRecurring ? _reminderMinutes : null),
        notes: Value(_notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim()),
      ));
    } else {
      await repo.insertCommitment(companion);

      // Auto-populate the Step 12 calendar when a recurring commitment is saved.
      // Creates 12 weekly events starting from the next occurrence of the
      // specified weekday/time, matching the same pattern used for meetings.
      if (_isRecurring && _recurringWeekday != null) {
        final timeStr = _buildRecurringTime() ?? '09:00';
        final step12Repo = ref.read(step12RepositoryProvider);
        final description = [
          if (_orgCtrl.text.trim().isNotEmpty) _orgCtrl.text.trim(),
          if (_notesCtrl.text.trim().isNotEmpty) _notesCtrl.text.trim(),
        ].join('\n');
        DateTime start = nextMeetingOccurrence(_recurringWeekday!, timeStr);
        for (var i = 0; i < 12; i++) {
          final end = start.add(const Duration(hours: 1));
          await step12Repo.insert(StepTwelveEventsCompanion(
            title: Value(title),
            description: Value(description.isEmpty ? null : description),
            startTime: Value(start),
            endTime: Value(end),
            eventType: const Value('service'),
          ));
          start = start.add(const Duration(days: 7));
        }
      }
    }

    if (mounted) Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add / Edit step call sheet
// ─────────────────────────────────────────────────────────────────────────────

class AddStepCallSheet extends ConsumerStatefulWidget {
  final TwelfthStepCall? existing;
  /// Start the sheet in "schedule future call" mode.
  final bool isScheduled;
  /// Pre-fill with a linked sponsee (from the Sponsees tab detail view).
  final int? sponseeId;
  final String? sponseeName;

  const AddStepCallSheet({
    this.existing,
    this.isScheduled = false,
    this.sponseeId,
    this.sponseeName,
  });

  @override
  ConsumerState<AddStepCallSheet> createState() =>
      _AddStepCallSheetState();
}

class _AddStepCallSheetState extends ConsumerState<AddStepCallSheet> {
  late final TextEditingController _personCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _outcomeCtrl;

  late StepCallType _callType;
  late DateTime _occurredAt;
  TimeOfDay? _time;
  late bool _isScheduledMode;

  static final _dateFmt = DateFormat('EEE, MMM d, yyyy');

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _personCtrl =
        TextEditingController(text: e?.person ?? widget.sponseeName ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _outcomeCtrl = TextEditingController(text: e?.outcome ?? '');
    _callType = e != null
        ? StepCallType.fromString(e.callType)
        : StepCallType.call;
    _isScheduledMode = e?.scheduledAt != null || widget.isScheduled;
    _occurredAt = e?.scheduledAt ?? e?.occurredAt ?? DateTime.now();
    if (e != null) {
      final ref = e.scheduledAt ?? e.occurredAt;
      if (ref.hour != 0 || ref.minute != 0) {
        _time = TimeOfDay(hour: ref.hour, minute: ref.minute);
      }
    }
  }

  @override
  void dispose() {
    _personCtrl.dispose();
    _descCtrl.dispose();
    _outcomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _DragHandle(),
            Text(
              _isEditing
                  ? 'Edit Entry'
                  : _isScheduledMode
                      ? 'Plan a Future Call'
                      : 'Log 12th Step Work',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // ── Schedule toggle (only on new entries) ─────────────────
            if (!_isEditing)
              SwitchListTile(
                value: _isScheduledMode,
                onChanged: (v) => setState(() {
                  _isScheduledMode = v;
                  // Reset date: past for log, near-future for schedule
                  _occurredAt = v ? tomorrow : now;
                  _time = v ? const TimeOfDay(hour: 10, minute: 0) : null;
                }),
                title: const Text('Schedule for the future',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(_isScheduledMode
                    ? 'Will appear in the Step 12 calendar'
                    : 'Log work that already happened'),
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.purple.shade600,
              ),
            const SizedBox(height: 8),

            // ── Type ──────────────────────────────────────────────────
            _FormLabel('Type'),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: StepCallType.values.map((t) {
                final sel = _callType == t;
                return FilterChip(
                  avatar: Icon(t.icon,
                      size: 15, color: sel ? Colors.white : t.color),
                  label: Text(t.label),
                  selected: sel,
                  onSelected: (_) => setState(() => _callType = t),
                  selectedColor: t.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : null,
                      fontWeight: sel ? FontWeight.w600 : null,
                      fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Person ────────────────────────────────────────────────
            TextField(
              controller: _personCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'First name (optional)',
                hintText: 'For your own reference — first name only',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // ── Date / time ───────────────────────────────────────────
            _FormLabel(_isScheduledMode ? 'Scheduled for' : 'When'),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _occurredAt,
                        firstDate: _isScheduledMode
                            ? now
                            : DateTime(2020),
                        lastDate: _isScheduledMode
                            ? DateTime(now.year + 5)
                            : now,
                      );
                      if (d != null) setState(() => _occurredAt = d);
                    },
                    icon: const Icon(Icons.calendar_today_outlined,
                        size: 16),
                    label: Text(_dateFmt.format(_occurredAt)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now(),
                      );
                      if (t != null) setState(() => _time = t);
                    },
                    icon: const Icon(Icons.schedule_outlined, size: 16),
                    label:
                        Text(_time != null ? _time!.format(context) : 'Time'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Description ───────────────────────────────────────────
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: _isScheduledMode
                    ? 'Notes / Purpose *'
                    : 'Description *',
                hintText: _isScheduledMode
                    ? 'Why are you planning this call?'
                    : 'What happened — brief notes for your record',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Outcome (only for logged calls) ───────────────────────
            if (!_isScheduledMode) ...[
              TextField(
                controller: _outcomeCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Outcome (optional)',
                  hintText: 'How did it go?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 12),

            // ── Save ──────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _isScheduledMode
                    ? Colors.purple.shade700
                    : Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                  _isEditing
                      ? 'Update Entry'
                      : _isScheduledMode
                          ? 'Schedule Call'
                          : 'Log Work',
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _buildDateTime() {
    if (_time == null) {
      return DateTime(_occurredAt.year, _occurredAt.month, _occurredAt.day);
    }
    return DateTime(_occurredAt.year, _occurredAt.month, _occurredAt.day,
        _time!.hour, _time!.minute);
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) return;

    final repo = ref.read(serviceCommitmentsRepositoryProvider);
    final dt = _buildDateTime();
    final personName = _personCtrl.text.trim().isEmpty
        ? null
        : _personCtrl.text.trim();

    if (_isEditing) {
      await repo.updateCall(widget.existing!.copyWith(
        callType: _callType.value,
        person: Value(personName),
        description: desc,
        outcome: Value(_outcomeCtrl.text.trim().isEmpty
            ? null
            : _outcomeCtrl.text.trim()),
        occurredAt: dt,
        scheduledAt: Value(_isScheduledMode ? dt : null),
      ));
    } else {
      await repo.insertCall(TwelfthStepCallsCompanion(
        callType: Value(_callType.value),
        person: Value(personName),
        description: Value(desc),
        outcome: Value(_outcomeCtrl.text.trim().isEmpty
            ? null
            : _outcomeCtrl.text.trim()),
        occurredAt: Value(dt),
        scheduledAt: Value(_isScheduledMode ? dt : null),
        sponseeId: Value(widget.sponseeId),
      ));

      // Create a calendar event for scheduled future calls.
      if (_isScheduledMode) {
        final step12Repo = ref.read(step12RepositoryProvider);
        await step12Repo.insert(StepTwelveEventsCompanion(
          title: Value(personName != null
              ? 'Call with $personName'
              : '12th Step Call'),
          description: Value(desc),
          startTime: Value(dt),
          endTime: Value(dt.add(const Duration(minutes: 60))),
          eventType: const Value('sponsee'),
        ));
      }
    }

    if (mounted) Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty states
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _ServiceEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism_outlined,
                size: 64, color: Colors.teal.shade200),
            const SizedBox(height: 20),
            const Text('No Service Commitments',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Track your service positions, speaking commitments, '
              'and recurring service work here.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Commitment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCallsEmptyState extends StatelessWidget {
  final VoidCallback onLog;
  const _StepCallsEmptyState({required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_in_talk_outlined,
                size: 64, color: Colors.blue.shade200),
            const SizedBox(height: 20),
            const Text('No 12th Step Work Logged',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Log your 12th-step calls, in-person visits, '
              'and sponsee interactions as you carry the message.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onLog,
              icon: const Icon(Icons.add),
              label: const Text('Log a Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared stub helpers
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Shared micro-widgets (used across service and step-call sheets)
// ─────────────────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey.shade700),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: color,
            letterSpacing: 0.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared stub helpers (used by _SponseeTab)
// ─────────────────────────────────────────────────────────────────────────────

class _ComingSoonBadge extends StatelessWidget {
  final Color color;
  const _ComingSoonBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        'Coming soon',
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class _FeaturePreviewList extends StatelessWidget {
  final Color color;
  final List<String> features;
  const _FeaturePreviewList(
      {required this.color, required this.features});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features.map((f) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(f,
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 14)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
