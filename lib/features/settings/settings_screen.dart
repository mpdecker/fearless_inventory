import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/database/database.dart';
import '../../core/navigation/adaptive_page_route.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/sobriety_provider.dart';
import '../../core/providers/sponsor_call_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/seed_data_service.dart';
import '../../core/services/sponsor_call_prefs.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../data/repositories/amends_repository.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/sponsor_call_repository.dart';
import '../../data/services/export_service.dart';
import '../auth/screens/account_screen.dart';
import '../auth/screens/pin_setup_screen.dart';
import '../insights/providers/insights_extended_providers.dart';
import '../meetings/providers/meeting_attendance_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../review/providers/insight_provider.dart';
import '../review/providers/streak_provider.dart';
import '../review/providers/trend_provider.dart';
import '../sponsor_call/sponsor_call_screen.dart';
import 'screens/literature_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Privacy')),
      body: ListView(
        children: [
          _buildSectionHeader('Data & Export'),

          // ── Big Book worksheet ─────────────────────────────────────────
          ListTile(
            leading:
                const Icon(Icons.table_rows_outlined, color: Colors.tealAccent),
            title: const Text('Big Book Step 4 Worksheet (PDF)'),
            subtitle: const Text(
                'Classic 4-column format for resentments, fears, and harms'),
            onTap: () => _handleBigBookPdf(context, ref),
          ),

          // ── Sponsor review sheet ───────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.supervised_user_circle_outlined,
                color: Colors.deepOrangeAccent),
            title: const Text('Export for Sponsor Review (PDF)'),
            subtitle: const Text(
                'Flagged items only — includes blank column for sponsor notes'),
            onTap: () => _handleSponsorReviewPdf(context, ref),
          ),

          // ── Sponsor app import (JSON) ──────────────────────────────────
          ListTile(
            leading: const Icon(Icons.ios_share_outlined,
                color: Colors.purpleAccent),
            title: const Text('Share Inventory with Sponsor (App Import)'),
            subtitle: const Text(
                'Creates a JSON file your sponsor can import directly in their Fearless Inventory app for a guided review'),
            onTap: () => _handleSponsorJsonExport(context, ref),
          ),

          // ── Original summary export ────────────────────────────────────
          ListTile(
            leading:
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            title: const Text('Export Summary PDF'),
            subtitle: const Text('Inventory and 10th Step patterns'),
            onTap: () => _handlePdfExport(ref),
          ),

          // ── Amends Excel / CSV ───────────────────────────────────────
          ListTile(
            leading:
                const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Export Amends to Excel'),
            subtitle: const Text('Full restitution plan with status columns'),
            onTap: () => _handleExcelExport(ref),
          ),
          ListTile(
            leading:
                const Icon(Icons.description_outlined, color: Colors.lightGreen),
            title: const Text('Export Amends to CSV'),
            subtitle: const Text(
                'UTF-8 spreadsheet — opens in Numbers, Sheets, or Excel'),
            onTap: () => _handleCsvExport(ref),
          ),

          // ── Journal PDF ────────────────────────────────────────────────
          ListTile(
            leading:
                const Icon(Icons.menu_book_outlined, color: Colors.indigoAccent),
            title: const Text('Export Recovery Journal (PDF)'),
            subtitle: const Text(
                'All journal entries formatted as a personal journal — '
                'grouped by Step and Tradition'),
            onTap: () => _handleJournalPdfExport(context, ref),
          ),

          const Divider(),
          _buildSectionHeader('Literature'),

          // ── Big Book ───────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.auto_stories_outlined,
                color: Color(0xFF1A56DB)),
            title: const Text('The Big Book'),
            subtitle: const Text(
                'Alcoholics Anonymous — chapter navigator with bookmarks'),
            onTap: () => Navigator.of(context).push(
              adaptivePageRoute((_) => const LiteratureScreen(initialTab: 0)),
            ),
          ),

          // ── 12 & 12 ────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.menu_book_outlined,
                color: Color(0xFF6D28D9)),
            title: const Text('Twelve Steps and Twelve Traditions'),
            subtitle: const Text(
                'The "12 & 12" — step and tradition chapters with bookmarks'),
            onTap: () => Navigator.of(context).push(
              adaptivePageRoute((_) => const LiteratureScreen(initialTab: 1)),
            ),
          ),

          const Divider(),
          _buildSectionHeader('Recovery'),

          // ── Sobriety date ──────────────────────────────────────────────
          _SobrietyDateTile(),

          const Divider(),
          _buildSectionHeader('Notifications'),

          const _NotificationsReminderTile(),

          const _SponsorCallReminderTile(),

          _SponsorCallLogTile(),

          const Divider(),
          _buildSectionHeader('Demo'),

          ListTile(
            leading: const Icon(Icons.science_outlined, color: Colors.tealAccent),
            title: const Text('Load Demo Data'),
            subtitle: const Text(
                '18-month recovery narrative — fills every screen and insight card for demonstration'),
            onTap: () => _loadDemoData(context, ref),
          ),

          const Divider(),
          _buildSectionHeader('Privacy'),

          ListTile(
            leading:
                const Icon(Icons.delete_forever, color: Colors.grey),
            title: const Text('Clear All Data'),
            subtitle:
                const Text('Permanently wipe all inventory, reviews, and amends from this device'),
            onTap: () => _confirmDataWipe(context, ref),
          ),

          const Divider(),
          _buildSectionHeader('Security'),

          // ── PIN management ─────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.pin_outlined, color: Colors.tealAccent),
            title: const Text('Change PIN'),
            subtitle: const Text('Update your 6-digit app-lock PIN'),
            onTap: () => Navigator.of(context).push(
              adaptivePageRoute((_) => const PinSetupScreen(isChangingPin: true)),
            ),
          ),

          const Divider(),
          _buildSectionHeader('Cloud Account'),

          // ── Cloud account ──────────────────────────────────────────────
          _CloudAccountTile(),

          const Divider(),
          _buildSectionHeader('Onboarding'),

          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined,
                color: Colors.indigoAccent),
            title: const Text('Replay Introduction'),
            subtitle: const Text(
                'View the opening walkthrough again'),
            onTap: () async {
              await OnboardingService.reset();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  adaptivePageRoute((_) => const OnboardingScreen()),
                  (_) => false,
                );
              }
            },
          ),

          const Divider(),
          _buildSectionHeader('About'),

          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.menu_book),
            title: Text('Not affiliated with AA World Services, Inc.'),
            subtitle: Text('Use with your sponsor.'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ── Export handlers ──────────────────────────────────────────────────────

  Future<void> _handleBigBookPdf(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final resentments = await repo.watchResentments().first;
    final fears = await repo.watchFears().first;
    final harms = await repo.watchHarms().first;

    await ExportService.generateBigBookWorksheetPdf(
      resentments: resentments,
      fears: fears,
      harms: harms,
    );
  }

  Future<void> _handleSponsorReviewPdf(
      BuildContext context, WidgetRef ref) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final resentments = await repo.watchResentments().first;
    final fears = await repo.watchFears().first;
    final harms = await repo.watchHarms().first;

    final flaggedCount = resentments.where((r) => r.flagForReview).length +
        fears.where((f) => f.flagForReview).length +
        harms.where((h) => h.flagForReview).length;

    if (flaggedCount == 0 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No items are flagged for sponsor review yet. "
            "Open a resentment, fear, or harm entry and tap "
            "'Flag for sponsor review'.",
          ),
        ),
      );
      return;
    }

    await ExportService.generateSponsorReviewPdf(
      resentments: resentments,
      fears: fears,
      harms: harms,
    );
  }

  Future<void> _handleSponsorJsonExport(
      BuildContext context, WidgetRef ref) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final resentments = await repo.watchResentments().first;
    final fears = await repo.watchFears().first;
    final harms = await repo.watchHarms().first;

    await ExportService.exportSponsorReviewJson(
      resentments: resentments,
      fears: fears,
      harms: harms,
    );
  }

  Future<void> _handlePdfExport(WidgetRef ref) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final resentments = await repo.watchResentments().first;
    final fears = await repo.watchFears().first;
    final harms = await repo.watchHarms().first;
    final reviews = await ref.read(reviewRepositoryProvider).watchAllReviews().first;

    await ExportService.generateInventoryPdf(
      resentments: resentments,
      fears: fears,
      harms: harms,
      reviews: reviews,
    );
  }

  Future<void> _handleExcelExport(WidgetRef ref) async {
    final amends = await ref.read(amendsRepositoryProvider).watchAll().first;
    await ExportService.exportToExcel(amends);
  }

  Future<void> _handleCsvExport(WidgetRef ref) async {
    final amends = await ref.read(amendsRepositoryProvider).watchAll().first;
    await ExportService.exportToCsv(amends);
  }

  Future<void> _handleJournalPdfExport(
      BuildContext context, WidgetRef ref) async {
    final entries =
        await ref.read(journalRepositoryProvider).getAllForExport();

    if (entries.isEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your journal is empty. Write some entries in the Journal tab first.',
          ),
        ),
      );
      return;
    }

    await ExportService.generateJournalPdf(entries);
  }

  // ── Data wipe ────────────────────────────────────────────────────────────

  void _confirmDataWipe(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will permanently delete all your inventory entries, '
          'daily reviews, amends, defects, and shortcomings from this device. '
          'There is no undo.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _executeDataWipe(context, ref);
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDemoData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Load Demo Data?'),
        content: const Text(
          'This will wipe all existing data and replace it with a realistic '
          '18-month recovery narrative.\n\n'
          'Every screen, insight card, and feature will have content to explore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Load Demo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    await SeedDataService(db).seed();

    // Refresh all providers so every screen reflects the seeded data immediately.
    ref.invalidate(sobrietyDateProvider);
    ref.invalidate(insightsProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(spiritualLandscapeProvider);
    ref.invalidate(journalInsightsProvider);
    ref.invalidate(weekActivityProvider);
    ref.invalidate(disturberBreakdownProvider);
    ref.invalidate(serviceInsightsProvider);
    ref.invalidate(amendsJourneyProvider);
    ref.invalidate(sponsorCallInsightsProvider);
    ref.invalidate(step10TypeInsightsProvider);
    ref.invalidate(meetingAttendanceStatsProvider);
    ref.invalidate(weeklyPillarsProvider);
    ref.invalidate(meetingMomentumProvider);
    ref.invalidate(fearInsightsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo data loaded — explore every screen!'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _executeDataWipe(BuildContext context, WidgetRef ref) async {
    // Second confirmation — prevents an accidental single-tap deletion
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'All inventory data will be gone. '
          'This cannot be recovered.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No, keep my data')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, delete everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(databaseProvider);
    await db.wipeAllData();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data has been deleted from this device.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ── Sobriety date tile ────────────────────────────────────────────────────────

class _SobrietyDateTile extends ConsumerWidget {
  _SobrietyDateTile();

  static final _dateFmt = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sobrietyAsync = ref.watch(sobrietyDateProvider);
    final currentDate = sobrietyAsync.maybeWhen(
      data: (d) => d,
      orElse: () => null,
    );

    final subtitle = currentDate != null
        ? _dateFmt.format(currentDate)
        : 'Not set — tap to add your sobriety date';

    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.teal),
      title: const Text('Sobriety Date'),
      subtitle: Text(subtitle),
      trailing: currentDate != null
          ? IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              tooltip: 'Clear sobriety date',
              onPressed: () => _confirmClear(context, ref),
            )
          : null,
      onTap: () => _pickDate(context, ref, currentDate),
    );
  }

  Future<void> _pickDate(
      BuildContext context, WidgetRef ref, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showAdaptiveAppDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Select your sobriety start date',
    );

    if (picked != null) {
      await ref.read(sobrietyDateProvider.notifier).setDate(picked);
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear sobriety date?'),
        content: const Text(
          'This will remove your sobriety date from the app. '
          'Your recovery data and Step work will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(sobrietyDateProvider.notifier).clearDate();
    }
  }
}

// ── Notification reminder (Settings) ─────────────────────────────────────────

/// Shows OS notification status and a one-line path to Settings when alerts
/// are denied. Does not request permission (avoids repeated prompts).
class _NotificationsReminderTile extends StatefulWidget {
  const _NotificationsReminderTile();

  @override
  State<_NotificationsReminderTile> createState() =>
      _NotificationsReminderTileState();
}

class _NotificationsReminderTileState extends State<_NotificationsReminderTile>
    with WidgetsBindingObserver {
  late Future<PermissionStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _statusFuture = Permission.notification.status;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _statusFuture = Permission.notification.status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final dailyT = loc.formatTimeOfDay(
      const TimeOfDay(
        hour: NotificationService.defaultDailyReviewHour,
        minute: NotificationService.defaultDailyReviewMinute,
      ),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final bedT = loc.formatTimeOfDay(
      const TimeOfDay(
        hour: NotificationService.defaultBedtimeHour,
        minute: NotificationService.defaultBedtimeMinute,
      ),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final scheduleSubtitle =
        'Daily review at $dailyT · Bedtime meditation at $bedT';

    return FutureBuilder<PermissionStatus>(
      future: _statusFuture,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final denied = status == PermissionStatus.denied ||
            status == PermissionStatus.permanentlyDenied ||
            status == PermissionStatus.restricted;

        if (status == null) {
          return const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Reminder alerts'),
            subtitle: Text('Checking…'),
          );
        }

        if (denied) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined,
                    color: Colors.orangeAccent),
                title: const Text('Reminder alerts'),
                subtitle: Text(
                  'Notifications are off. Daily review and bedtime '
                  'reminders will not appear. Turn them on in system Settings '
                  'if you want them — we will not ask again here.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextButton.icon(
                  onPressed: openAppSettings,
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  label: const Text('Open system settings'),
                ),
              ),
            ],
          );
        }

        return ListTile(
          leading:
              const Icon(Icons.notifications_active, color: Colors.tealAccent),
          title: const Text('Reminder alerts'),
          subtitle: Text(scheduleSubtitle),
        );
      },
    );
  }
}

// ── Sponsor call reminder tile ────────────────────────────────────────────────

/// Shows the current sponsor-call reminder schedule and opens a configuration
/// sheet when tapped.
class _SponsorCallReminderTile extends ConsumerWidget {
  const _SponsorCallReminderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(sponsorCallConfigProvider);

    final subtitle = configAsync.maybeWhen(
      data: (c) {
        if (!c.enabled) return 'Tap to configure';
        final timeStr = _formatTime(context, c.hour, c.minute);
        if (c.frequency == 'weekly') {
          final dayName = _weekdayName(c.weekday);
          return 'Weekly — $dayName at $timeStr';
        }
        return 'Daily at $timeStr';
      },
      orElse: () => 'Loading…',
    );

    return ListTile(
      leading: Icon(
        Icons.phone_forwarded_outlined,
        color: configAsync.maybeWhen(
          data: (c) => c.enabled ? Colors.tealAccent : Colors.blueGrey,
          orElse: () => Colors.blueGrey,
        ),
      ),
      title: const Text('Call your sponsor reminder'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.tune_outlined, color: Colors.white38),
      onTap: () => _openConfigSheet(context, ref),
    );
  }

  Future<void> _openConfigSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SponsorCallConfigSheet(ref: ref),
    );
  }

  static String _formatTime(BuildContext context, int hour, int minute) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatTimeOfDay(
      TimeOfDay(hour: hour, minute: minute),
      alwaysUse24HourFormat:
          MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }

  static String _weekdayName(int weekday) {
    const names = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday'
    ];
    return weekday >= 1 && weekday <= 7 ? names[weekday] : '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Configuration bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SponsorCallConfigSheet extends StatefulWidget {
  final WidgetRef ref;
  const _SponsorCallConfigSheet({required this.ref});

  @override
  State<_SponsorCallConfigSheet> createState() =>
      _SponsorCallConfigSheetState();
}

class _SponsorCallConfigSheetState extends State<_SponsorCallConfigSheet> {
  late SponsorCallConfig _draft;
  final _phoneController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final current = widget.ref
        .read(sponsorCallConfigProvider)
        .maybeWhen(data: (c) => c, orElse: () => SponsorCallConfig.defaults);
    _draft = current;
    _phoneController.text = current.phone ?? '';
    _loaded = true;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final padding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            'Call your sponsor reminder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),

          // ── Enable toggle ─────────────────────────────────────────────────
          SwitchListTile(
            value: _draft.enabled,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(enabled: v)),
            title: const Text('Enable reminder'),
            activeColor: Colors.tealAccent,
            contentPadding: EdgeInsets.zero,
          ),

          const Divider(),

          if (_draft.enabled) ...[
            // ── Frequency chips ───────────────────────────────────────────
            const Text('Repeat', style: TextStyle(color: Colors.blueGrey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _FrequencyChip(
                  label: 'Daily',
                  selected: _draft.frequency == 'daily',
                  onTap: () =>
                      setState(() => _draft = _draft.copyWith(frequency: 'daily')),
                ),
                const SizedBox(width: 8),
                _FrequencyChip(
                  label: 'Weekly',
                  selected: _draft.frequency == 'weekly',
                  onTap: () =>
                      setState(() => _draft = _draft.copyWith(frequency: 'weekly')),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Day of week (weekly only) ─────────────────────────────────
            if (_draft.frequency == 'weekly') ...[
              const Text('Day', style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (i) {
                    final weekday = i + 1; // 1=Mon…7=Sun
                    const abbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FrequencyChip(
                        label: abbr[i],
                        selected: _draft.weekday == weekday,
                        onTap: () =>
                            setState(() => _draft = _draft.copyWith(weekday: weekday)),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Time ──────────────────────────────────────────────────────
            const Text('Time', style: TextStyle(color: Colors.blueGrey)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.access_time_outlined),
              label: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  TimeOfDay(hour: _draft.hour, minute: _draft.minute),
                  alwaysUse24HourFormat:
                      MediaQuery.alwaysUse24HourFormatOf(context),
                ),
              ),
              onPressed: () => _pickTime(context),
            ),
            const SizedBox(height: 20),
          ],

          // ── Phone number ───────────────────────────────────────────────────
          const Text("Sponsor's phone number",
              style: TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'e.g. +1 555 000 1234',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // ── Save ───────────────────────────────────────────────────────────
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _save(context),
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _draft.hour, minute: _draft.minute),
    );
    if (picked != null) {
      setState(() =>
          _draft = _draft.copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  Future<void> _save(BuildContext context) async {
    final phone = _phoneController.text.trim();
    final finalConfig = _draft.copyWith(
      phone: phone.isNotEmpty ? phone : null,
      clearPhone: phone.isEmpty,
    );
    await widget.ref.read(sponsorCallConfigProvider.notifier).save(finalConfig);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _FrequencyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FrequencyChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.tealAccent : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.tealAccent : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ── Sponsor call log-a-call tile ──────────────────────────────────────────────

/// Shows the last logged sponsor call and navigates to [SponsorCallScreen]
/// for manual call logging.
class _SponsorCallLogTile extends ConsumerWidget {
  _SponsorCallLogTile();

  static final _dateFmt = DateFormat('MMM d');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastCallAsync = ref.watch(_sponsorCallLastProvider);

    final subtitle = lastCallAsync.maybeWhen(
      data: (last) {
        if (last == null) return 'No calls logged yet — tap to log one';
        final diff = DateTime.now().difference(last.confirmedAt);
        if (diff.inDays == 0) return 'Last called today';
        if (diff.inDays == 1) return 'Last called yesterday';
        return 'Last called ${_dateFmt.format(last.confirmedAt)} — ${diff.inDays} days ago';
      },
      orElse: () => 'Loading…',
    );

    return ListTile(
      leading: const Icon(Icons.phone_callback_outlined, color: Colors.teal),
      title: const Text('Log a sponsor call'),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: () => Navigator.of(context).push(
        adaptivePageRoute((_) => const SponsorCallScreen()),
      ),
    );
  }
}

final _sponsorCallLastProvider =
    StreamProvider.autoDispose<SponsorCallLog?>((ref) {
  return ref.watch(sponsorCallRepositoryProvider).watchLastCall();
});

// ── Cloud account tile ────────────────────────────────────────────────────────

/// Shows a brief summary of the user's cloud account state and links to the
/// full [AccountScreen] for sign-in / registration / deletion.
class _CloudAccountTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(firebaseUserProvider);

    return userAsync.when(
      loading: () => const ListTile(
        leading: Icon(Icons.cloud_outlined, color: Colors.blueGrey),
        title: Text('Cloud Account'),
        subtitle: Text('Loading…'),
      ),
      error: (_, __) => ListTile(
        leading:
            const Icon(Icons.cloud_off_outlined, color: Colors.blueGrey),
        title: const Text('Cloud Account'),
        subtitle: const Text('Unavailable'),
        onTap: () => Navigator.of(context).push(
          adaptivePageRoute((_) => const AccountScreen()),
        ),
      ),
      data: (user) => ListTile(
        leading: Icon(
          user != null ? Icons.cloud_done_outlined : Icons.cloud_outlined,
          color: user != null ? Colors.tealAccent : Colors.blueGrey,
        ),
        title: const Text('Cloud Account'),
        subtitle: Text(
          user != null
              ? user.email ?? 'Signed in'
              : 'No account — optional',
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () => Navigator.of(context).push(
          adaptivePageRoute((_) => const AccountScreen()),
        ),
      ),
    );
  }
}
