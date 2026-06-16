import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/adaptive_page_route.dart';
import '../data/step_tradition_content.dart';
import '../providers/journal_providers.dart';
import 'journal_list_screen.dart';
import 'step_journal_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JournalTab
// ─────────────────────────────────────────────────────────────────────────────

/// Root widget for the Journal bottom-navigation tab.
///
/// Two sub-tabs: Steps (1–12) and Traditions (1–12), each shown as a
/// 3-column grid.  Each card displays the entry count and navigates to
/// [StepJournalScreen] on tap.
class JournalTab extends ConsumerStatefulWidget {
  const JournalTab({super.key});

  @override
  ConsumerState<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends ConsumerState<JournalTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAsync = ref.watch(journalTotalCountProvider);
    final totalCount = totalAsync.maybeWhen(data: (n) => n, orElse: () => 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.list_alt_outlined),
                tooltip: 'All entries',
                onPressed: () => Navigator.push(
                  context,
                  adaptivePageRoute((_) => const JournalListScreen()),
                ),
              ),
              if (totalCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.indigoPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      totalCount > 99 ? '99+' : '$totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'The Steps'),
            Tab(text: 'The Traditions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _SubjectGrid(
            items: StepTraditionContent.steps,
            countBuilder: (number) =>
                ref.watch(stepEntryCountProvider(number)),
          ),
          _SubjectGrid(
            items: StepTraditionContent.traditions,
            countBuilder: (number) =>
                ref.watch(traditionEntryCountProvider(number)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectGrid extends StatelessWidget {
  final List<JournalSubjectContent> items;
  final AsyncValue<int> Function(int number) countBuilder;

  // ignore: prefer_const_constructors_in_immutables
  _SubjectGrid({required this.items, required this.countBuilder});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final content = items[index];
        return _SubjectCard(
          content: content,
          countAsync: countBuilder(content.number),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual card
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final JournalSubjectContent content;
  final AsyncValue<int> countAsync;

  // ignore: prefer_const_constructors_in_immutables
  _SubjectCard({required this.content, required this.countAsync});

  @override
  Widget build(BuildContext context) {
    final colors = _cardColors(content);
    final count = countAsync.maybeWhen(data: (n) => n, orElse: () => 0);

    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          adaptivePageRoute(
            (_) => StepJournalScreen(content: content),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.first.withOpacity(0.08),
                colors.last.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative number (large, background) ──────────────────
              Positioned(
                top: -6,
                right: -4,
                child: Text(
                  '${content.number}',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: colors.first.withOpacity(0.06),
                    height: 1,
                  ),
                ),
              ),

              // ── Main content ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.first.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colors.first,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Expanded(
                      child: Text(
                        content.title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.85),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Entry count
                    Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 11,
                          color: count > 0
                              ? colors.first.withOpacity(0.7)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.25),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          count == 0
                              ? 'No entries'
                              : count == 1
                                  ? '1 entry'
                                  : '$count entries',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: count > 0
                                ? colors.first.withOpacity(0.7)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: card accent colors by step group
// ─────────────────────────────────────────────────────────────────────────────

List<Color> _cardColors(JournalSubjectContent content) {
  if (content.type == JournalSubjectType.tradition) {
    return [AppColors.accentDeepPurple, AppColors.accentPurple];
  }
  final n = content.number;
  if (n <= 3) return [AppColors.indigoPrimary, AppColors.lightIndigo];
  if (n <= 9) return [AppColors.accentDeepOrange, AppColors.accentOrange];
  return [AppColors.cyanSecondary, AppColors.brightCyan];
}
