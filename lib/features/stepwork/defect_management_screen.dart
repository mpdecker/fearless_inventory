import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/defect_repository.dart';
// New Import for the Wizard
import 'defect_discovery_wizard.dart';

final defectsListProvider = StreamProvider<List<Defect>>((ref) {
  return ref.watch(defectRepositoryProvider).watchAll();
});

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
              MaterialPageRoute(builder: (_) => const DefectDiscoveryWizard()),
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
                itemCount: defects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final defect = defects[index];
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
              "No defects identified yet.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap the magic wand icon above to start the Discovery Wizard and identify defects from your Step 4 inventory.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
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
        title: const Text("Step 6 Readiness"),
        content: const Text(
          "We are now ready to have God remove all these defects of character which we admit are objectionable. Are we now entirely ready?\n\n- Big Book p. 76",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it")),
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
          ? const Text("Entirely ready for removal", style: TextStyle(color: Colors.teal, fontSize: 12)) 
          : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: defect.isReady,
              onChanged: (val) {
                ref.read(defectRepositoryProvider).updateDefect(
                  defect.copyWith(isReady: val ?? false),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => ref.read(defectRepositoryProvider).delete(defect.id),
            ),
          ],
        ),
      ),
    );
  }
}