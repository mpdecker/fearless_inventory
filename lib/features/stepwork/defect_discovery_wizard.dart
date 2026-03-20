import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/repositories/defect_repository.dart';

// Provider to fetch items from Step 4 that haven't been "processed" yet
final discoveryItemsProvider = FutureProvider<List<Resentment>>((ref) async {
  final db = ref.read(databaseProvider);
  // Process in batches of 10 for better focus
  return (db.select(db.resentments)..limit(10)).get(); 
});

class DefectDiscoveryWizard extends ConsumerStatefulWidget {
  const DefectDiscoveryWizard({super.key});

  @override
  ConsumerState<DefectDiscoveryWizard> createState() => _DefectDiscoveryWizardState();
}

class _DefectDiscoveryWizardState extends ConsumerState<DefectDiscoveryWizard> {
  int _currentIndex = 0;
  final List<String> _commonDefects = [
    'Self-Pity', 'Pride', 'Greed', 'Lust', 'Anger', 
    'Gluttony', 'Envy', 'Sloth', 'Fear', 'Dishonesty', 'Selfishness'
  ];

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(discoveryItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Discovery Wizard")),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty || _currentIndex >= items.length) {
            return _buildCompletionState();
          }
          final currentResentment = items[_currentIndex];
          return _buildWizardStep(currentResentment);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildWizardStep(Resentment resentment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("LOOKING AT THE INVENTORY:", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 8),
          Card(
            color: Colors.indigo.shade50,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "I am resentful at ${resentment.person} because ${resentment.cause}.",
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("What defect of character allowed this to happen?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8, // Prevents chips from overlapping vertically
            children: _commonDefects.map((defect) => ActionChip(
              label: Text(defect),
              onPressed: () => _saveDefect(defect),
            )).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: "Other / Custom Defect",
              hintText: "Enter a custom defect name",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.add),
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (val) => _saveDefect(val),
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _currentIndex++),
              child: const Text("Skip this item"),
            ),
          )
        ],
      ),
    );
  }

  void _saveDefect(String name) async {
    if (name.isEmpty) return;
    
    await ref.read(defectRepositoryProvider).insert(
      DefectsCompanion(
        name: Value(name.trim()),
        createdAt: Value(DateTime.now()),
        isReady: const Value(false),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added '$name' to your Step 6 list"), 
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _currentIndex++);
  }

  Widget _buildCompletionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text("Batch Complete!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "You've reviewed your recent inventory items and translated them into character defects.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Return to Defects List"),
            )
          ],
        ),
      ),
    );
  }
}