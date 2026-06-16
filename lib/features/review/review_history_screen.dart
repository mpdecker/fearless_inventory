import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/database.dart';
import 'providers/review_providers.dart';

class ReviewHistoryScreen extends ConsumerWidget {
  const ReviewHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 10 History'),
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (reviews) => reviews.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.track_changes_outlined,
                          size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet.\nComplete your first Step 10 review on the Dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade500, height: 1.6),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: reviews.length,
                itemBuilder: (_, i) =>
                    _ReviewCard(review: reviews[i], isFirst: i == 0),
              ),
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final DailyReview review;
  final bool isFirst;
  const _ReviewCard({required this.review, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final hasDisturbers = review.wasResentful ||
        review.wasSelfish ||
        review.wasDishonest ||
        review.wasAfraid;
    final color = hasDisturbers ? Colors.orange.shade700 : Colors.green.shade600;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFirst
              ? color.withAlpha(100)
              : Colors.grey.shade200,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  _typeIcon(review.reviewType),
                  size: 15,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('EEE, MMM d').format(review.date),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  _typeLabel(review.reviewType),
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasDisturbers ? 'Growth' : 'Clean',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                ),
              ],
            ),

            // ── Disturber chips ──────────────────────────────────────────
            if (hasDisturbers) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  if (review.wasResentful) _chip('Resentful'),
                  if (review.wasSelfish) _chip('Selfish'),
                  if (review.wasDishonest) _chip('Dishonest'),
                  if (review.wasAfraid) _chip('Afraid'),
                ],
              ),
            ],

            // ── Notes / gratitude excerpt ────────────────────────────────
            if (review.notes != null && review.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.shade200, width: 0.8),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700),
        ),
      );
}

IconData _typeIcon(String? type) {
  switch (type) {
    case 'morning':
      return Icons.wb_sunny_outlined;
    case 'spot_check':
      return Icons.track_changes_outlined;
    default:
      return Icons.bedtime_outlined;
  }
}

String _typeLabel(String? type) {
  switch (type) {
    case 'morning':
      return 'Morning';
    case 'spot_check':
      return 'Spot check';
    default:
      return 'Nightly';
  }
}
