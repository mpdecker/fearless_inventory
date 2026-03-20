import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/services/reflection_service.dart';

// 1. Data Provider: Orchestrates signals from DB and fetches reflection
final step11ReflectionProvider = FutureProvider<Reflection?>((ref) async {
  final db = ref.read(databaseProvider);
  
  // Fetch the most recent Daily Review to extract trait signals
  final lastReview = await (db.select(db.dailyReviews)
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(1))
      .getSingleOrNull();

  List<String> signals = [];
  if (lastReview != null) {
    if (lastReview.wasResentful) signals.add('resentful');
    if (lastReview.wasAfraid) signals.add('afraid');
    if (lastReview.wasDishonest) signals.add('dishonest');
    if (lastReview.wasSelfish) signals.add('selfish');
  }

  // Also include descriptions of current shortcomings logged in Step 7
  final recentShortcomings = await (db.select(db.shortcomingLogs)
        ..limit(5))
      .get();
  for (var log in recentShortcomings) {
    signals.add(log.description);
  }

  // Use your existing service to get the "Antidote" reflection
  return ReflectionService().getReflectionForSignals(signals);
});

class Step11MeditationScreen extends ConsumerWidget {
  const Step11MeditationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditationAsync = ref.watch(step11ReflectionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Step 11 Meditation"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
      ),
      body: meditationAsync.when(
        data: (reflection) => reflection == null 
            ? const Center(child: Text("Start your day with a reflection."))
            : _buildContent(context, reflection),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Reflection reflection) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "MEDITATION THEME: ${reflection.theme.toUpperCase()}",
              style: TextStyle(
                color: Colors.indigo.shade900, 
                fontWeight: FontWeight.bold, 
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quote Section
          Text(
            reflection.quote,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Divider(thickness: 0.5),
          ),
          // Long-form Reflection
          const Text("THE REFLECTION", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo)),
          const SizedBox(height: 16),
          Text(
            reflection.reflection,
            style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 48),
          _buildMorningPrayer(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.indigo.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("I am ready for the day", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMorningPrayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          Text(
            "“God, direct my thinking today; especially that it be divorced from self-pity, dishonest or self-seeking motives.”",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, height: 1.4),
          ),
        ],
      ),
    );
  }
}