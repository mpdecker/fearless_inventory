import 'package:flutter/material.dart';

import '../../core/navigation/adaptive_page_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/theme/app_colors.dart';
import '../../core/database/database.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/shortcomings_repository.dart';
import '../../core/services/notification_service.dart';
import '../stepwork/defect_discovery_wizard.dart';
import '../amends/amends_entry_screen.dart';
import 'review_type.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Questions & labels per review context
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCopy {
  final String title;
  final String resentfulQ;
  final String selfishQ;
  final String dishonestQ;
  final String afraidQ;
  final String notesLabel;
  final String gratitudeLabel;
  final String saveButton;
  final Color accent;

  const _ReviewCopy({
    required this.title,
    required this.resentfulQ,
    required this.selfishQ,
    required this.dishonestQ,
    required this.afraidQ,
    required this.notesLabel,
    required this.gratitudeLabel,
    required this.saveButton,
    required this.accent,
  });
}

_ReviewCopy _copyFor(ReviewType type) => switch (type) {
      ReviewType.morning => const _ReviewCopy(
          title: 'Morning 10th Step',
          resentfulQ: 'Am I carrying resentment into today?',
          selfishQ: 'Am I entering the day with self-seeking motives?',
          dishonestQ: 'Is there anything dishonest about my plans today?',
          afraidQ: 'Am I starting today with fear?',
          notesLabel: 'Intentions & prayers for today',
          gratitudeLabel: 'What am I grateful for as I begin today?',
          saveButton: 'Begin My Day',
          accent: AppColors.accentDeepOrange,
        ),
      ReviewType.spotCheck => const _ReviewCopy(
          title: 'Spot Check',
          resentfulQ: 'Am I being resentful right now?',
          selfishQ: 'Am I acting selfishly or self-seeking?',
          dishonestQ: 'Am I being dishonest in this situation?',
          afraidQ: 'Am I acting out of fear?',
          notesLabel: 'What happened? What was my part?',
          gratitudeLabel: 'What can I do differently?',
          saveButton: 'Log This Event',
          accent: AppColors.cyanSecondary,
        ),
      ReviewType.nightly => const _ReviewCopy(
          title: 'Nightly 10th Step',
          resentfulQ: 'Was I resentful today?',
          selfishQ: 'Was I selfish today?',
          dishonestQ: 'Was I dishonest today?',
          afraidQ: 'Was I afraid today?',
          notesLabel: 'Notes / Amends needed',
          gratitudeLabel: 'What am I grateful for today?',
          saveButton: 'Complete Review',
          accent: AppColors.indigoPrimary,
        ),
    };

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class DailyReviewScreen extends HookConsumerWidget {
  final ReviewType reviewType;
  const DailyReviewScreen({
    super.key,
    this.reviewType = ReviewType.nightly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _copyFor(reviewType);

    final wasResentful = useState(false);
    final wasSelfish = useState(false);
    final wasDishonest = useState(false);
    final wasAfraid = useState(false);
    final notesController = useTextEditingController();
    final gratitudeController = useTextEditingController();

    void _showShortcomingLogger(BuildContext ctx, int reviewId) {
      final logController = TextEditingController(text: notesController.text);
      showDialog(
        context: ctx,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Log Shortcoming'),
          content: TextField(
            controller: logController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Briefly describe the shortcoming instance...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(shortcomingRepositoryProvider).insert(
                      ShortcomingLogsCompanion(
                        description: Value(logController.text),
                        dateObserved: Value(DateTime.now()),
                        relatedReviewId: Value(reviewId),
                      ),
                    );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Log & Finish'),
            ),
          ],
        ),
      );
    }

    void _showSignalFollowUp(BuildContext ctx, int reviewId) {
      final isSpotCheck = reviewType == ReviewType.spotCheck;
      showModalBottomSheet(
        context: ctx,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Growth Opportunity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isSpotCheck
                    ? 'You spotted something in this situation. How would you like to proceed?'
                    : 'You identified some inventory items today. How would you like to proceed?',
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: Colors.indigo),
                title: const Text('Run Discovery Wizard'),
                subtitle:
                    const Text('Translate these into character defects (Step 6)'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushReplacement(
                    ctx,
                    adaptivePageRoute((_) => const DefectDiscoveryWizard()),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.self_improvement, color: Colors.teal),
                title: const Text('Log a Shortcoming'),
                subtitle: const Text('Track this instance for Step 7 prayer'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showShortcomingLogger(ctx, reviewId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake_outlined,
                    color: Colors.deepOrange),
                title: const Text('Plan an Amends'),
                subtitle: const Text('Add a Step 9 amends plan for harm done'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    ctx,
                    adaptivePageRoute((_) => const AmendsEntryScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Just Save & Finish'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Future<void> saveReview() async {
      final repo = ref.read(reviewRepositoryProvider);
      final now = DateTime.now();

      final reviewId = await repo.insertReview(DailyReviewsCompanion(
        date: Value(now),
        wasResentful: Value(wasResentful.value),
        wasSelfish: Value(wasSelfish.value),
        wasDishonest: Value(wasDishonest.value),
        wasAfraid: Value(wasAfraid.value),
        notes: Value(notesController.text),
        gratitude: Value(gratitudeController.text),
        reviewType: Value(reviewType.dbValue),
        createdAt: Value(now),
      ));

      // Reschedule daily review notification
      final notifications = NotificationService();
      await notifications.cancelNotification(NotificationService.idDailyReview);
      await notifications.scheduleDailyReviewReminder(
        hour: NotificationService.defaultDailyReviewHour,
        minute: NotificationService.defaultDailyReviewMinute,
      );
      await notifications.scheduleBedtimeMeditationReminder(
        hour: NotificationService.defaultBedtimeHour,
        minute: NotificationService.defaultBedtimeMinute,
      );

      if (context.mounted) {
        final hasSignals = wasResentful.value ||
            wasSelfish.value ||
            wasDishonest.value ||
            wasAfraid.value;

        // Morning reviews: just save — no signal follow-up
        if (reviewType == ReviewType.morning || !hasSignals) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${copy.title} saved')),
          );
        } else {
          _showSignalFollowUp(context, reviewId);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.title),
        backgroundColor: copy.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildToggleItem(copy.resentfulQ, wasResentful, copy.accent),
            _buildToggleItem(copy.selfishQ, wasSelfish, copy.accent),
            _buildToggleItem(copy.dishonestQ, wasDishonest, copy.accent),
            _buildToggleItem(copy.afraidQ, wasAfraid, copy.accent),
            const SizedBox(height: 24),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: copy.notesLabel,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gratitudeController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: copy.gratitudeLabel,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: saveReview,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: copy.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(copy.saveButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
      String title, ValueNotifier<bool> state, Color accent) {
    return SwitchListTile(
      title: Text(title),
      value: state.value,
      activeColor: accent,
      onChanged: (val) => state.value = val,
    );
  }
}
