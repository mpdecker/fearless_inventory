import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/shortcomings_repository.dart';
import '../../core/services/notification_service.dart';
// New imports for Step 6/7 integration
import '../stepwork/defect_discovery_wizard.dart';

class DailyReviewScreen extends HookConsumerWidget {
  const DailyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wasResentful = useState(false);
    final wasSelfish = useState(false);
    final wasDishonest = useState(false);
    final wasAfraid = useState(false);
    final notesController = useTextEditingController();
    final gratitudeController = useTextEditingController();

    // Helper to show the Step 7 Shortcoming logging dialog
    void _showShortcomingLogger(BuildContext context, int reviewId) {
      final logController = TextEditingController(text: notesController.text);
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Log Shortcoming"),
          content: TextField(
            controller: logController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Briefly describe the shortcoming instance...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
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
                  Navigator.pop(dialogContext); // Close Dialog
                  Navigator.pop(context); // Return to Home
                }
              },
              child: const Text("Log & Finish"),
            ),
          ],
        ),
      );
    }

    // Helper to show the growth opportunity modal
    void _showSignalFollowUp(BuildContext context, int reviewId) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Growth Opportunity", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("You identified some inventory items tonight. How would you like to proceed?"),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: Colors.indigo),
                title: const Text("Run Discovery Wizard"),
                subtitle: const Text("Translate these into character defects (Step 6)"),
                onTap: () {
                  Navigator.pop(sheetContext); // Close sheet
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => const DefectDiscoveryWizard()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.self_improvement, color: Colors.teal),
                title: const Text("Log a Shortcoming"),
                subtitle: const Text("Track this instance for Step 7 prayer"),
                onTap: () {
                  Navigator.pop(sheetContext); // Close sheet
                  _showShortcomingLogger(context, reviewId);
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(context); // Return to Home
                  },
                  child: const Text("Just Save & Finish"),
                ),
              )
            ],
          ),
        ),
      );
    }

    Future<void> saveReview() async {
      final repo = ref.read(reviewRepositoryProvider);
      
      final reviewId = await repo.insertReview(DailyReviewsCompanion(
        date: Value(DateTime.now()),
        wasResentful: Value(wasResentful.value),
        wasSelfish: Value(wasSelfish.value),
        wasDishonest: Value(wasDishonest.value),
        wasAfraid: Value(wasAfraid.value),
        notes: Value(notesController.text),
        gratitude: Value(gratitudeController.text),
        createdAt: Value(DateTime.now()),
      ));

      // Notification Logic
      final notifications = NotificationService();
      await notifications.cancelAll(); 
      await notifications.scheduleDailyReviewReminder(hour: 21, minute: 0);

      if (context.mounted) {
        // STEP 10 SIGNAL INTEGRATION:
        // Check if any negative traits were flagged
        final hasSignals = wasResentful.value || wasSelfish.value || 
                           wasDishonest.value || wasAfraid.value;

        if (hasSignals) {
          _showSignalFollowUp(context, reviewId);
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('10th Step Review Saved')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Daily 10th Step')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildToggleItem("Was I resentful today?", wasResentful),
            _buildToggleItem("Was I selfish today?", wasSelfish),
            _buildToggleItem("Was I dishonest today?", wasDishonest),
            _buildToggleItem("Was I afraid today?", wasAfraid),
            const SizedBox(height: 24),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Notes / Amends needed",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: gratitudeController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "What am I grateful for?",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: saveReview,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Complete Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, ValueNotifier<bool> state) {
    return SwitchListTile(
      title: Text(title),
      value: state.value,
      activeColor: Colors.indigo,
      onChanged: (val) => state.value = val,
    );
  }
}