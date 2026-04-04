import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/navigation/adaptive_page_route.dart';
import '../../data/repositories/fear_repository.dart';
import 'providers/inventory_providers.dart'; // Import the new dedicated provider file
import 'fear_entry_screen.dart';

class FearListScreen extends ConsumerWidget {
  const FearListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the fearsStreamProvider for real-time updates
    final fearsAsync = ref.watch(fearsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('4th Step: Fears'),
      ),
      body: fearsAsync.when(
        // Handle the data state: display the list or an empty message
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  'No fears recorded yet.\nTap + to start your Fear Inventory.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    title: Text(item.subject),
                    subtitle: Text(
                      item.why,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref.read(fearRepositoryProvider).deleteFear(item.id),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      adaptivePageRoute(
                        (_) => FearEntryScreen(existing: item),
                      ),
                    ),
                  );
                },
              ),
        // Handle the loading state
        loading: () => const Center(child: CircularProgressIndicator()),
        // Handle the error state
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          adaptivePageRoute((_) => const FearEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}