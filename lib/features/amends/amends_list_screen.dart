import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/widgets/quote_card.dart';
import 'providers/amends_providers.dart';
import 'amends_entry_screen.dart'; // also exports timeframeLabel

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
            : (item.status == 'pending' || item.status == 'completed')).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    filterStatus == 'step8'
                        ? Icons.format_list_bulleted
                        : Icons.handshake_outlined,
                    size: 56,
                    color: Colors.deepOrange.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    filterStatus == 'step8'
                        ? 'No items in your Step 8 list yet.'
                        : 'No active amends plans.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  QuoteCard(
                    quote: filterStatus == 'step8'
                        ? RecoveryQuotes.step8List
                        : RecoveryQuotes.step9Timing,
                    compact: true,
                  ),
                ],
              ),
            ),
          );
        }

        // Pick a daily-rotating quote from the appropriate step pool.
        final quotes = filterStatus == 'step8'
            ? RecoveryQuotes.step8Quotes
            : RecoveryQuotes.step9Quotes;
        final headerQuote = quotes[DateTime.now().day % quotes.length];

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          // index 0 = quote header; rest = amends items
          itemCount: filtered.length + 1,
          separatorBuilder: (_, i) =>
              i == 0 ? const SizedBox(height: 4) : const Divider(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return QuoteCard(quote: headerQuote, compact: true);
            }
            final item = filtered[index - 1];
            final bool isDone = item.status == 'completed';

            return ListTile(
              leading: Checkbox(
                activeColor: Colors.deepOrange.shade800,
                value: isDone,
                onChanged: (val) =>
                    ref.read(amendsUpdateProvider)(item.id, val ?? false),
              ),
              title: Text(
                item.person,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.plan ?? 'No plan yet — tap to add'),
                  const SizedBox(height: 4),
                  _TimeframeBadge(amend: item),
                ],
              ),
              isThreeLine: item.plan != null ||
                  item.timeframe != null ||
                  item.datePlanned != null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AmendsEntryScreen(editAmends: item)),
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

// ── Timeframe badge ───────────────────────────────────────────────────────────

class _TimeframeBadge extends StatelessWidget {
  final Amend amend;
  const _TimeframeBadge({required this.amend});

  @override
  Widget build(BuildContext context) {
    String? label;
    IconData icon;

    if (amend.timeframe != null) {
      label = timeframeLabel(amend.timeframe);
      icon = Icons.schedule_outlined;
    } else if (amend.datePlanned != null) {
      final d = amend.datePlanned!;
      label = '${d.month}/${d.day}/${d.year}';
      icon = Icons.calendar_today_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.deepOrange.shade400),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: Colors.deepOrange.shade400,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}