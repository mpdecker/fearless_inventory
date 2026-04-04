import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/navigation/adaptive_page_route.dart';
import 'providers/inventory_providers.dart';
import 'harm_entry_screen.dart';
import '../amends/amends_entry_screen.dart';

class HarmListScreen extends ConsumerWidget {
  const HarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the StreamProvider (AsyncValue)
    final harmAsync = ref.watch(harmListStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harms & Sex Conduct'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showStep4Info(context),
          ),
        ],
      ),
      body: harmAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No harms recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return ListTile(
                    title: Text(item.person, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(item.conduct, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.playlist_add_check),
                      color: Colors.deepOrange.shade600,
                      tooltip: 'Plan Amends',
                      onPressed: () {
                        Navigator.push(
                          context,
                          adaptivePageRoute(
                              (_) => AmendsEntryScreen(fromHarm: item)),
                        );
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      adaptivePageRoute(
                          (_) => HarmEntryScreen(existing: item)),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange.shade800,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          adaptivePageRoute((_) => const HarmEntryScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showStep4Info(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Harm & Sex Conduct"),
        content: const Text(
          "We review our own conduct over the years past... Whom had we hurt? - Big Book p. 69",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it")),
        ],
      ),
    );
  }
}