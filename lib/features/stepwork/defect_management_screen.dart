import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/navigation/adaptive_page_route.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/widgets/quote_card.dart';
import '../../data/repositories/defect_repository.dart';
import 'defect_discovery_wizard.dart';
import 'providers/defect_providers.dart';

class DefectManagementScreen extends ConsumerWidget {
  const DefectManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defectsAsync = ref.watch(defectsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Character Defects"),
        actions: [
          // Added Discovery Wizard Launcher
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: "Discovery Wizard",
            onPressed: () => Navigator.push(
              context,
              adaptivePageRoute((_) => const DefectDiscoveryWizard()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showStep6Info(context),
          ),
        ],
      ),
      body: defectsAsync.when(
        data: (defects) => defects.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                // index 0 = daily quote header; rest = defect cards
                itemCount: defects.length + 1,
                separatorBuilder: (_, i) =>
                    i == 0 ? const SizedBox(height: 4) : const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) return _DefectQuoteHeader();
                  final defect = defects[index - 1];
                  return _DefectCard(defect: defect);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text("Error loading defects: $e")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDefectDialog(context, ref),
        label: const Text("Add Defect"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.indigo.shade200),
            const SizedBox(height: 16),
            const Text(
              'No defects identified yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the magic wand icon above to start the Discovery Wizard '
              'and identify defects from your Step 4 inventory.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const QuoteCard(
              quote: RecoveryQuotes.step6Ready,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDefectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Character Defect"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g., Perfectionism, Pride"),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(defectRepositoryProvider).insert(
                  DefectsCompanion(
                    name: Value(controller.text.trim()),
                    createdAt: Value(DateTime.now()),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showStep6Info(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Step 6 Readiness'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuoteCard(quote: RecoveryQuotes.step6Ready),
            SizedBox(height: 8),
            QuoteCard(quote: RecoveryQuotes.step6Willing, compact: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _DefectCard extends ConsumerWidget {
  final Defect defect;
  const _DefectCard({required this.defect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(defect.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: defect.isReady
            ? const Text("Entirely ready for removal",
                style: TextStyle(color: Colors.teal, fontSize: 12))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ready checkbox ───────────────────────────────────────
            Checkbox(
              value: defect.isReady,
              onChanged: (val) {
                ref.read(defectRepositoryProvider).updateDefect(
                  defect.copyWith(isReady: val ?? false),
                );
              },
            ),
            // ── Edit ────────────────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              tooltip: 'Rename defect',
              onPressed: () => _showEditDialog(context, ref),
            ),
            // ── Delete ──────────────────────────────────────────────
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete defect',
              onPressed: () => ref.read(defectRepositoryProvider).delete(defect.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: defect.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Character Defect'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Perfectionism, Pride'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(defectRepositoryProvider)
                    .updateDefect(defect.copyWith(name: name));
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily-rotating quote header for the defects list
// ─────────────────────────────────────────────────────────────────────────────

class _DefectQuoteHeader extends StatelessWidget {
  const _DefectQuoteHeader();

  @override
  Widget build(BuildContext context) {
    // Rotate through Steps 6 & 7 quotes — changes each calendar day.
    final quotes = RecoveryQuotes.step6And7Quotes;
    final quote = quotes[DateTime.now().day % quotes.length];
    return QuoteCard(quote: quote, compact: true);
  }
}