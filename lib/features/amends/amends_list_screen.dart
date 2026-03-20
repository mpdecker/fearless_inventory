import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';
import 'providers/amends_providers.dart';
import 'amends_entry_screen.dart';

class AmendsListScreen extends ConsumerWidget {
  const AmendsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amends Workspace'),
          bottom: const TabBar(
            indicatorColor: Colors.deepOrange,
            tabs: [
              Tab(text: "Step 8: List", icon: Icon(Icons.format_list_bulleted)),
              Tab(text: "Step 9: Action", icon: Icon(Icons.bolt)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AmendsFilteredList(filterStatus: 'step8'),
            _AmendsFilteredList(filterStatus: 'pending'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange.shade800,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AmendsEntryScreen()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _AmendsFilteredList extends ConsumerWidget {
  final String filterStatus;
  const _AmendsFilteredList({required this.filterStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amendsAsync = ref.watch(amendsListProvider);

    return amendsAsync.when(
      data: (list) {
        final filtered = list.where((item) => filterStatus == 'step8' 
            ? item.status == 'step8' 
            : (item.status == 'pending' || item.status == 'Completed')).toList();

        if (filtered.isEmpty) {
          return Center(child: Text(filterStatus == 'step8' 
              ? 'No items in Step 8 list.' 
              : 'No active amends plans.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = filtered[index];
            final bool isDone = item.status == 'Completed';

            return ListTile(
              leading: Checkbox(
                activeColor: Colors.deepOrange.shade800,
                value: isDone,
                onChanged: (val) => ref.read(amendsUpdateProvider)(item.id, val ?? false),
              ),
              title: Text(item.person, style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isDone ? TextDecoration.lineThrough : null,
              )),
              subtitle: Text(item.plan ?? "No plan yet - Tap to add"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AmendsEntryScreen(editAmends: item)),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}