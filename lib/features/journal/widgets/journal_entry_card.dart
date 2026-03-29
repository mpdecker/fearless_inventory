import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database.dart';
import '../data/step_tradition_content.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

final _dateFmt = DateFormat('MMM d, yyyy');
final _timeFmt = DateFormat('h:mm a');

String _contextLabel(JournalEntry entry) {
  if (entry.stepNumber != null) return 'Step ${entry.stepNumber}';
  if (entry.traditionNumber != null) return 'Tradition ${entry.traditionNumber}';
  return 'General';
}

Color _contextColor(JournalEntry entry) {
  if (entry.stepNumber != null) {
    final n = entry.stepNumber!;
    if (n <= 3) return const Color(0xFF3F51B5);  // Indigo — Steps 1–3
    if (n <= 9) return const Color(0xFFE65100);  // Deep orange — Steps 4–9
    return const Color(0xFF00695C);              // Dark teal — Steps 10–12
  }
  if (entry.traditionNumber != null) {
    return const Color(0xFF6A1B9A);              // Deep purple — Traditions
  }
  return Colors.blueGrey;
}

// ─────────────────────────────────────────────────────────────────────────────
// JournalEntryCard
// ─────────────────────────────────────────────────────────────────────────────

/// Compact card used in the master journal list and the step/tradition page.
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  /// Called when the user taps the card (navigate to edit).
  final VoidCallback? onTap;

  /// Called when the user confirms deletion.
  final VoidCallback? onDelete;

  const JournalEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _contextColor(entry);
    final label = _contextLabel(entry);
    final preview = entry.content.length > 160
        ? '${entry.content.substring(0, 160).trimRight()}…'
        : entry.content;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Context chip + date row ──────────────────────────────────
              Row(
                children: [
                  _ContextChip(label: label, color: color),
                  const Spacer(),
                  Text(
                    _dateFmt.format(entry.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 4),
                    _DeleteButton(onDelete: onDelete!),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // ── Title ───────────────────────────────────────────────────
              if (entry.title != null && entry.title!.isNotEmpty) ...[
                Text(
                  entry.title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],

              // ── Preview ─────────────────────────────────────────────────
              Text(
                preview,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.75),
                ),
              ),

              // ── Prompt badge ─────────────────────────────────────────────
              if (entry.promptId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Written from a prompt',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ContextChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ContextChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.delete_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: const Text(
          'This journal entry will be permanently removed from your device. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline entry (larger, for the master list)
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [JournalEntryCard] with a left timeline accent line.
class JournalTimelineEntry extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isLast;

  const JournalTimelineEntry({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _contextColor(entry);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline line + dot ────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned.fill(
                    top: 18,
                    child: Center(
                      child: Container(width: 1.5, color: color.withOpacity(0.2)),
                    ),
                  ),
                Positioned(
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Card ──────────────────────────────────────────────────────
          Expanded(
            child: JournalEntryCard(
              entry: entry,
              onTap: onTap,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
