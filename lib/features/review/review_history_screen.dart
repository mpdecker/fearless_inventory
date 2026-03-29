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

    return reviewsAsync.when(
      data: (reviews) => reviews.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No reviews recorded yet.', 
                  style: TextStyle(color: Colors.grey)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final dateStr = DateFormat('EEEE, MMM d').format(review.date);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildIndicatorRow(review),
                        if (review.notes != null && review.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Notes: ${review.notes}', 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13)),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildIndicatorRow(DailyReview review) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _statusChip('Resentful', review.wasResentful),
        _statusChip('Selfish', review.wasSelfish),
        _statusChip('Dishonest', review.wasDishonest),
        _statusChip('Afraid', review.wasAfraid),
      ],
    );
  }

  Widget _statusChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? Colors.red.shade300 : Colors.green.shade300, 
          width: 0.8
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10, 
          fontWeight: FontWeight.w500,
          color: active ? Colors.red.shade700 : Colors.green.shade700
        ),
      ),
    );
  }
}