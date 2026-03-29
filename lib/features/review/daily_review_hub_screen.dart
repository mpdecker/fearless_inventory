import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/quotes/recovery_quotes.dart';
import '../../core/widgets/quote_card.dart';
import 'daily_review_screen.dart';
import 'review_history_screen.dart';
import 'providers/review_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Hub screen
// ─────────────────────────────────────────────────────────────────────────────

/// Landing screen for Step 10.  Shows all incidents already logged today and
/// lets the user add as many additional entries as needed.
class DailyReviewHubScreen extends ConsumerWidget {
  const DailyReviewHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayReviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 10: Daily Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Review history',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ReviewHistoryScreen()),
            ),
          ),
        ],
      ),
      body: todayAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reviews) => reviews.isEmpty
            ? _EmptyTodayView(onAdd: () => _openEntry(context))
            : _TodayIncidentList(
                reviews: reviews,
                onAdd: () => _openEntry(context),
              ),
      ),
      floatingActionButton: todayAsync.maybeWhen(
        data: (r) => r.isEmpty
            ? null // empty state has its own CTA
            : FloatingActionButton.extended(
                onPressed: () => _openEntry(context),
                icon: const Icon(Icons.add),
                label: const Text('Log Another Incident'),
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
              ),
        orElse: () => null,
      ),
    );
  }

  void _openEntry(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DailyReviewScreen()),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyTodayView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTodayView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nightlight_round_outlined,
                size: 72, color: Colors.indigo.shade200),
            const SizedBox(height: 24),
            Text(
              'No inventory logged today',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const QuoteCard(quote: RecoveryQuotes.step10Evening, compact: true),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Begin Today\'s Review'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 52),
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Incident list
// ─────────────────────────────────────────────────────────────────────────────

class _TodayIncidentList extends StatelessWidget {
  final List<DailyReview> reviews;
  final VoidCallback onAdd;

  const _TodayIncidentList(
      {required this.reviews, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Day summary ──────────────────────────────────────────────────
        _DaySummaryHeader(reviews: reviews),
        const SizedBox(height: 16),

        // ── Individual incidents ─────────────────────────────────────────
        ...reviews.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _IncidentCard(
                incident: e.value,
                number: e.key + 1,
              ),
            )),

        // ── Quote footer ──────────────────────────────────────────────────
        const QuoteCard(quote: RecoveryQuotes.step10Promptly, compact: true),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Tap the button below to log another incident.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day summary header
// ─────────────────────────────────────────────────────────────────────────────

class _DaySummaryHeader extends StatelessWidget {
  final List<DailyReview> reviews;
  const _DaySummaryHeader({required this.reviews});

  @override
  Widget build(BuildContext context) {
    // Aggregate signal flags across all today's incidents
    final resentful = reviews.any((r) => r.wasResentful);
    final selfish = reviews.any((r) => r.wasSelfish);
    final dishonest = reviews.any((r) => r.wasDishonest);
    final afraid = reviews.any((r) => r.wasAfraid);

    final count = reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_outlined,
                  color: Colors.indigo.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                'Today — $count incident${count == 1 ? '' : 's'} logged',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _SignalChip('Resentful', Icons.whatshot_outlined, resentful),
              _SignalChip('Selfish', Icons.person_outline, selfish),
              _SignalChip('Dishonest', Icons.visibility_off_outlined, dishonest),
              _SignalChip('Afraid', Icons.warning_amber_outlined, afraid),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  const _SignalChip(this.label, this.icon, this.active);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon,
          size: 14,
          color: active ? Colors.white : Colors.grey.shade400),
      label: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: active ? Colors.white : Colors.grey.shade500)),
      backgroundColor:
          active ? Colors.indigo.shade600 : Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual incident card
// ─────────────────────────────────────────────────────────────────────────────

class _IncidentCard extends StatelessWidget {
  final DailyReview incident;
  final int number;
  const _IncidentCard({required this.incident, required this.number});

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final hasSignals = incident.wasResentful ||
        incident.wasSelfish ||
        incident.wasDishonest ||
        incident.wasAfraid;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: hasSignals
                ? Colors.indigo.shade200
                : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.indigo.shade100,
                  child: Text('$number',
                      style: TextStyle(
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text(_formatTime(incident.createdAt),
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
                const Spacer(),
                if (hasSignals)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('Has inventory',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.indigo.shade600,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),

            // ── Signal flags ──────────────────────────────────────────
            if (hasSignals) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (incident.wasResentful)
                    _MiniFlag('Resentful', Colors.red),
                  if (incident.wasSelfish)
                    _MiniFlag('Selfish', Colors.orange),
                  if (incident.wasDishonest)
                    _MiniFlag('Dishonest', Colors.amber.shade700),
                  if (incident.wasAfraid)
                    _MiniFlag('Afraid', Colors.purple),
                ],
              ),
            ],

            // ── Notes ─────────────────────────────────────────────────
            if (incident.notes != null &&
                incident.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                incident.notes!,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700),
              ),
            ],

            // ── Gratitude ─────────────────────────────────────────────
            if (incident.gratitude != null &&
                incident.gratitude!.trim().isNotEmpty) ...[
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.favorite_border,
                      size: 14, color: Colors.teal.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      incident.gratitude!,
                      style: TextStyle(
                          fontSize: 12, color: Colors.teal.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniFlag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniFlag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}
