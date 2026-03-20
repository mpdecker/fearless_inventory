import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../amends/providers/amends_stats_provider.dart';
import '../review/providers/insight_provider.dart';
import '../review/providers/trend_provider.dart';

class RecoveryInsightsScreen extends ConsumerWidget {
  const RecoveryInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landscapeAsync = ref.watch(spiritualLandscapeProvider);
    final insights = ref.watch(recoveryInsightProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Insights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Spiritual Landscape (14 Days)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          landscapeAsync.when(
            data: (data) => Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: data.map((d) => _LandscapeSquare(day: d)).toList()),
            )),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text("Error loading landscape"),
          ),
          const SizedBox(height: 32),
          const Text("Compassionate Observations", style: TextStyle(fontWeight: FontWeight.bold)),
          ...insights.map((text) => Card(child: ListTile(title: Text(text)))),
        ],
      ),
    );
  }
}

class _LandscapeSquare extends StatelessWidget {
  final DayReflection day;
  const _LandscapeSquare({required this.day});
  @override
  Widget build(BuildContext context) {
    Color color = day.intensity > 2 ? Colors.orange.shade200 : (day.intensity > 0 ? Colors.orange.shade50 : Colors.teal.shade50);
    return Column(
      children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        Text(DateFormat('E').format(day.date)[0], style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}