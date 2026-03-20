import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
// FIXED: Path updated to match your physical file name (shortcomings_repository.dart)
import '../../data/repositories/shortcomings_repository.dart'; 

final shortcomingsStreamProvider = StreamProvider<List<ShortcomingLog>>((ref) {
  return ref.watch(shortcomingRepositoryProvider).watchAll();
});

class ShortcomingDashboardScreen extends ConsumerWidget {
  const ShortcomingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(shortcomingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Step 7: Shortcomings")),
      body: logsAsync.when(
        data: (logs) => logs.isEmpty 
          ? _buildEmptyState() 
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(logs[index].description),
                  subtitle: Text("Observed: ${logs[index].dateObserved.toString().split(' ')[0]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(shortcomingRepositoryProvider).delete(logs[index].id),
                  ),
                ),
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 64, color: Colors.teal),
            SizedBox(height: 16),
            Text("No Shortcomings Logged", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "Shortcomings identified during your Daily 10th Step will appear here for Step 7 prayer and meditation.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}