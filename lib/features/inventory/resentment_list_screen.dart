import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';
import '../../data/repositories/resentment_repository.dart';
import 'resentment_entry_screen.dart';

// Provider to manage the stream of resentments
final resentmentsStreamProvider = StreamProvider<List<Resentment>>((ref) {
  return ref.watch(resentmentRepositoryProvider).watchAllResentments();
});

class ResentmentListScreen extends ConsumerWidget {
  const ResentmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resentmentsAsync = ref.watch(resentmentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('4th Step: Resentments'),
      ),
      body: resentmentsAsync.when(
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  'No resentments recorded yet.\nTap + to begin your inventory.',
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    title: Text(item.person),
                    subtitle: Text(
                      item.cause,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // FIX: Pass item.id because deleteResentment expects an int
                        ref.read(resentmentRepositoryProvider).deleteResentment(item.id);
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResentmentEntryScreen(existing: item),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResentmentEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}