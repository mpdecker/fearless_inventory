import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/providers/sobriety_provider.dart';
import '../../data/services/export_service.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/amends_repository.dart';
import '../../core/database/database.dart';
import '../onboarding/onboarding_screen.dart';

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

          // ── Amends Excel ───────────────────────────────────────────────
          ListTile(
            leading:
                const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Export Amends to Excel'),
            subtitle: const Text('Full restitution plan with status columns'),
            onTap: () => _handleExcelExport(ref),
          ),

          const Divider(),
          _buildSectionHeader('Recovery'),

          // ── Sobriety date ──────────────────────────────────────────────
          _SobrietyDateTile(),

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
                  MaterialPageRoute(
                      builder: (_) => const OnboardingScreen()),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Select your sobriety start date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.teal,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
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
