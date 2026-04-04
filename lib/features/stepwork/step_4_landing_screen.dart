import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/navigation/adaptive_page_route.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/widgets/quote_card.dart';
import '../../data/repositories/step5_repository.dart';
import '../inventory/resentment_list_screen.dart';
import '../inventory/fear_list_screen.dart';
import '../inventory/harm_list_screen.dart';
import 'step_5_ceremony_screen.dart';

/// Loads the latest Step 5 completion status so the landing screen can
/// show the correct CTA state.
final _step5StatusProvider = FutureProvider.autoDispose<DateTime?>((ref) {
  return ref.watch(step5RepositoryProvider).latestCompletion().then(
        (c) => c?.completedAt,
      );
});

class Step4LandingScreen extends ConsumerWidget {
  const Step4LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step5Async = ref.watch(_step5StatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Step 4: Moral Inventory')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const QuoteCard(quote: RecoveryQuotes.step4Resentment),
          const QuoteCard(quote: RecoveryQuotes.step4Inventory, compact: true),
          const SizedBox(height: 8),

          _buildInventoryTile(
            context,
            'Resentment Inventory',
            'The "number one" offender.',
            Icons.format_list_bulleted,
            Colors.redAccent,
            const ResentmentListScreen(),
          ),
          _buildInventoryTile(
            context,
            'Fear Inventory',
            'Reviewing our fears thoroughly.',
            Icons.warning_amber_rounded,
            Colors.amber.shade800,
            const FearListScreen(),
          ),
          _buildInventoryTile(
            context,
            'Sex & Harm Inventory',
            'Reviewing our own conduct.',
            Icons.people_outline,
            Colors.teal,
            const HarmListScreen(),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Step 5 CTA ───────────────────────────────────────────────────
          step5Async.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (lastCompleted) => _Step5Card(lastCompleted: lastCompleted),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTile(BuildContext context, String title,
      String subtitle, IconData icon, Color color, Widget screen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
            context, adaptivePageRoute((_) => screen)),
      ),
    );
  }
}

class _Step5Card extends StatelessWidget {
  final DateTime? lastCompleted;
  const _Step5Card({required this.lastCompleted});

  @override
  Widget build(BuildContext context) {
    final hasCompleted = lastCompleted != null;
    final dateStr = hasCompleted
        ? lastCompleted!.toIso8601String().split('T').first
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E2A44),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.handshake_outlined,
                      color: Color(0xFF00BFA5), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Step 5: Completion Ceremony',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasCompleted
                            ? 'Completed $dateStr — tap to redo'
                            : 'Admit the exact nature of your wrongs',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (hasCompleted)
                  const Icon(Icons.check_circle_outline,
                      color: Color(0xFF00BFA5), size: 20),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  adaptivePageRoute((_) => const Step5CeremonyScreen()),
                ),
                child: Text(
                  hasCompleted ? 'Begin Again' : 'Begin Step 5',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
