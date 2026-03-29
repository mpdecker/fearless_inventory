import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/journal_repository.dart';
import '../data/step_tradition_content.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_entry_card.dart';
import 'journal_entry_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filter model
// ─────────────────────────────────────────────────────────────────────────────

enum JournalFilter { all, steps, traditions }

// ─────────────────────────────────────────────────────────────────────────────
// JournalListScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Master list of all journal entries with search and filter chips.
class JournalListScreen extends HookConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allJournalEntriesProvider);
    final searchCtrl = useTextEditingController();
    final searchQuery = useState('');
    final activeFilter = useState(JournalFilter.all);

    useEffect(() {
      searchCtrl.addListener(() => searchQuery.value = searchCtrl.text);
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Journal Entries'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              // ── Search bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search entries…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchCtrl.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              // ── Filter chips ─────────────────────────────────────────────
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: JournalFilter.values.map((f) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(_filterLabel(f)),
                        selected: activeFilter.value == f,
                        onSelected: (_) => activeFilter.value = f,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body: allAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final filtered = _applyFilter(all, activeFilter.value, searchQuery.value);
          if (filtered.isEmpty) {
            return _EmptyState(
              hasEntries: all.isNotEmpty,
              query: searchQuery.value,
            );
          }
          // Group by month for timeline display
          final grouped = _groupByMonth(filtered);
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: _itemCount(grouped),
            itemBuilder: (context, index) =>
                _buildItem(context, ref, grouped, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JournalEntryForm()),
        ),
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  static String _filterLabel(JournalFilter f) {
    switch (f) {
      case JournalFilter.all: return 'All';
      case JournalFilter.steps: return 'Steps';
      case JournalFilter.traditions: return 'Traditions';
    }
  }

  static List<JournalEntry> _applyFilter(
    List<JournalEntry> all,
    JournalFilter filter,
    String query,
  ) {
    var result = all;
    switch (filter) {
      case JournalFilter.all:
        break;
      case JournalFilter.steps:
        result = result.where((e) => e.stepNumber != null).toList();
      case JournalFilter.traditions:
        result = result.where((e) => e.traditionNumber != null).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((e) =>
              (e.title?.toLowerCase().contains(q) ?? false) ||
              e.content.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  // ── Timeline grouping ──────────────────────────────────────────────────────

  static final _monthFmt = DateFormat('MMMM yyyy');

  static Map<String, List<JournalEntry>> _groupByMonth(
      List<JournalEntry> entries) {
    final map = <String, List<JournalEntry>>{};
    for (final e in entries) {
      final key = _monthFmt.format(e.createdAt);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  static int _itemCount(Map<String, List<JournalEntry>> grouped) {
    var count = 0;
    for (final list in grouped.values) {
      count += 1 + list.length; // header + entries
    }
    return count;
  }

  static Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<JournalEntry>> grouped,
    int globalIndex,
  ) {
    int cursor = 0;
    for (final entry in grouped.entries) {
      if (globalIndex == cursor) {
        return _MonthHeader(label: entry.key);
      }
      cursor++;
      for (int i = 0; i < entry.value.length; i++) {
        if (globalIndex == cursor) {
          final je = entry.value[i];
          final isLast = i == entry.value.length - 1;
          return JournalTimelineEntry(
            entry: je,
            isLast: isLast,
            onTap: () {
              final subject = je.stepNumber != null
                  ? StepTraditionContent.forStep(je.stepNumber!)
                  : je.traditionNumber != null
                      ? StepTraditionContent.forTradition(je.traditionNumber!)
                      : null;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JournalEntryForm(
                    entry: je,
                    subject: subject,
                  ),
                ),
              );
            },
            onDelete: () => ref.read(journalRepositoryProvider).delete(je.id),
          );
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final String label;

  const _MonthHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasEntries;
  final String query;

  const _EmptyState({required this.hasEntries, required this.query});

  @override
  Widget build(BuildContext context) {
    final message = query.isNotEmpty
        ? 'No entries match "$query".'
        : hasEntries
            ? 'No entries match the current filter.'
            : 'Your journal is empty.\n\nTap the pencil icon or open a Step\nto write your first entry.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
