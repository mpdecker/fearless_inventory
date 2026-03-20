import 'package:flutter/material.dart';
import 'daily_review_screen.dart';
import 'review_history_screen.dart';

class ReviewTab extends StatelessWidget {
  const ReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section 1: Action Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_task),
            label: const Text("Complete Daily 10th Step"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyReviewScreen()),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const Divider(height: 1),
        // Section 2: Historical List
        const Expanded(
          child: ReviewHistoryScreen(), 
        ),
      ],
    );
  }
}