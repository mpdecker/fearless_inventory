import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/daily_aa_reflection_provider.dart';
import '../../data/repositories/meditation_repository.dart';
import '../../core/widgets/meditation_timer.dart';
import 'morning_transition_screen.dart';
import '../review/daily_review_screen.dart';
import '../review/review_type.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class Step11MeditationScreen extends HookConsumerWidget {
  const Step11MeditationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflectionAsync = ref.watch(dailyAaReflectionBodyProvider);
    final sessionSaved    = useState(false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Step 11 Meditation'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade800,
      ),
      body: reflectionAsync.when(
        data: (body) => body != null && body.trim().length > 40
            ? _buildContent(context, ref, body.trim(), sessionSaved)
            : _buildEmpty(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildEmpty(),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Today\'s Daily Reflection could not be loaded.\n'
          'Ensure the AA Daily Reflections PDF is bundled.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
        ),
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String body,
    ValueNotifier<bool> sessionSaved,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Text(
            'AA Daily Reflection',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.indigo.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat.yMMMMd().format(DateTime.now()),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 0.5),
          ),

          // ── Reflection body ────────────────────────────────────────────
          SelectableText(
            body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),

          // ── Morning prayer ────────────────────────────────────────────
          _buildMorningPrayer(),
          const SizedBox(height: 20),

          // ── Morning 10th Step review ──────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const DailyReviewScreen(reviewType: ReviewType.morning),
              ),
            ),
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Morning 10th Step'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.orange.shade800,
              side: BorderSide(color: Colors.orange.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 28),

          // ── Meditation timer ──────────────────────────────────────────
          MeditationTimerWidget(
            accentColor: Colors.indigo.shade700,
            onSave: (seconds) async {
              await ref.read(meditationRepositoryProvider).saveSession(
                    sessionType:     'morning',
                    reflectionTheme: 'daily_reflection',
                    reflectionKey:   'daily_reflection',
                    durationSeconds: seconds,
                  );
              sessionSaved.value = true;
            },
          ),
          const SizedBox(height: 28),

          // ── Completion button ─────────────────────────────────────────
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const MorningTransitionScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 700),
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.indigo.shade800,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              sessionSaved.value
                  ? 'Session saved — carry on'
                  : 'I am ready for the day',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
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
      child: const Text(
        '"God, direct my thinking today; especially that it be divorced '
        'from self-pity, dishonest or self-seeking motives."',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.blueGrey,
          height: 1.45,
          fontSize: 14,
        ),
      ),
    );
  }
}
