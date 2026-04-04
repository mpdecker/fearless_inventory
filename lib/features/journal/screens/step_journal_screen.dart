import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/navigation/adaptive_page_route.dart';
import '../../../core/widgets/quote_card.dart';
import '../../../data/repositories/journal_repository.dart';
import '../data/step_tradition_content.dart';
import '../providers/journal_providers.dart';
import '../services/prompt_service.dart';
import '../widgets/journal_entry_card.dart';
import 'journal_entry_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StepJournalScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Landing page for a single Step or Tradition.
///
/// Displays the full step/tradition text, key themes, curated literature
/// passages, contemplative prompts, and all journal entries for that topic.
class StepJournalScreen extends ConsumerWidget {
  final JournalSubjectContent content;

  const StepJournalScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStep = content.type == JournalSubjectType.step;
    final AsyncValue<List<JournalEntry>> entriesAsync = isStep
        ? ref.watch(stepJournalEntriesProvider(content.number))
        : ref.watch(traditionJournalEntriesProvider(content.number));

    final prompts = ref.read(promptServiceProvider).getPrompts(content);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Sliver app bar with step text ────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.fromLTRB(56, 0, 16, 14),
              // Collapsed title — thematic label only; the step/tradition
              // number already appears once in the expanded header background.
              title: Text(
                content.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradientColors(content),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Step number (bold) above the step text — both the
                  // largest text on the page.
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 64,
                    bottom: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ── Number label ─────────────────────────────
                        Text(
                          content.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ── Canonical step / tradition text ───────────
                        Flexible(
                          child: Text(
                            content.text,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.93),
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              height: 1.55,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── All content sections ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thematic title (subordinate to the header) ────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ── Themes ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    children: content.themes
                        .map((t) => _ThemeChip(label: t, content: content))
                        .toList(),
                  ),
                ),

                // ── Description ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ),

                // ── Passages from the literature ──────────────────────────
                if (content.quotes.isNotEmpty) ...[
                  _SectionHeader('Passages from the Literature'),
                  ...content.quotes.map((q) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: QuoteCard(quote: q, compact: false),
                      )),
                  const SizedBox(height: 8),
                ],

                // ── Contemplative prompts ─────────────────────────────────
                if (prompts.isNotEmpty) ...[
                  _SectionHeader('Contemplative Prompts'),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Tap a prompt to open a new journal entry pre-loaded with it.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                  ...prompts.asMap().entries.map((entry) {
                    return _PromptCard(
                      prompt: entry.value,
                      index: entry.key + 1,
                      content: content,
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // ── Journal entries ───────────────────────────────────────
                _EntriesSection(
                  entriesAsync: entriesAsync,
                  content: content,
                ),

                const SizedBox(height: 100), // room for FAB
              ],
            ),
          ),
        ],
      ),

      // ── FAB — new entry ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          adaptivePageRoute(
            (_) => JournalEntryForm(subject: content),
          ),
        ),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Write Entry'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: gradient colors per step/tradition group
// ─────────────────────────────────────────────────────────────────────────────

List<Color> _gradientColors(JournalSubjectContent content) {
  if (content.type == JournalSubjectType.tradition) {
    return [const Color(0xFF4A148C), const Color(0xFF6A1B9A)];
  }
  final n = content.number;
  if (n <= 3) return [const Color(0xFF283593), const Color(0xFF3F51B5)];
  if (n <= 9) return [const Color(0xFFBF360C), const Color(0xFFE64A19)];
  return [const Color(0xFF004D40), const Color(0xFF00695C)];
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title.toUpperCase(),
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

class _ThemeChip extends StatelessWidget {
  final String label;
  final JournalSubjectContent content;

  const _ThemeChip({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors(content);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colors.first.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.first.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.first,
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final ContemplativePrompt prompt;
  final int index;
  final JournalSubjectContent content;

  const _PromptCard({
    required this.prompt,
    required this.index,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          adaptivePageRoute(
            (_) => JournalEntryForm(
              subject: content,
              initialPrompt: prompt,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prompt.text,
                  style: const TextStyle(fontSize: 14, height: 1.55),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntriesSection extends ConsumerWidget {
  final AsyncValue<List<JournalEntry>> entriesAsync;
  final JournalSubjectContent content;

  // ignore: prefer_const_constructors_in_immutables
  _EntriesSection({
    required this.entriesAsync,
    required this.content,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return entriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error loading entries: $e'),
      ),
      data: (entries) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'MY ENTRIES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${entries.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (entries.isEmpty)
              _EmptyState(content: content)
            else
              ...entries.map((entry) => JournalEntryCard(
                    entry: entry,
                    onTap: () => Navigator.push(
                      context,
                      adaptivePageRoute(
                        (_) => JournalEntryForm(
                          subject: content,
                          entry: entry,
                        ),
                      ),
                    ),
                    onDelete: () => ref
                        .read(journalRepositoryProvider)
                        .delete(entry.id),
                  )),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final JournalSubjectContent content;

  const _EmptyState({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.edit_note_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No entries yet for ${content.label}.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap a prompt above or use "Write Entry" to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
