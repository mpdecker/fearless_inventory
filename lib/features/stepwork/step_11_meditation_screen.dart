import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/services/reflection_service.dart';
import '../../data/repositories/meditation_repository.dart';
import '../../core/widgets/meditation_timer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// autoDispose ensures the reflection is recomputed on every screen open
/// so today's Step-10 signals are always included.
final step11ReflectionProvider =
    FutureProvider.autoDispose<Reflection?>((ref) async {
  final db = ref.read(databaseProvider);

  // ── Step 1: gather weights & recency map from DB ─────────────────────────
  // Wrapped in try-catch: if the meditation_sessions table doesn't exist yet
  // (e.g. build_runner hasn't been run, or migration pending), we gracefully
  // fall back to empty maps so a reflection still loads.
  var themeWeights = <String, double>{};
  var recentKeys   = <String, DateTime>{};

  try {
    final repo = ref.read(meditationRepositoryProvider);
    final results = await Future.wait([
      repo.getThemeWeights(),
      repo.getRecentReflectionKeys(),
    ]);
    themeWeights = Map<String, double>.from(results[0] as Map);
    recentKeys   = Map<String, DateTime>.from(results[1] as Map);
  } catch (_) {
    // DB not fully migrated yet — continue with empty maps; default themes apply
  }

  // ── Step 2: boost today's active signals ─────────────────────────────────
  try {
    final lastReview = await (db.select(db.dailyReviews)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    if (lastReview != null) {
      void boost(bool flag, String signal) {
        if (!flag) return;
        for (final theme
            in ReflectionService.signalToThemes[signal] ?? <String>[]) {
          themeWeights[theme] = (themeWeights[theme] ?? 0) + 2.0;
        }
      }
      boost(lastReview.wasResentful, 'resentful');
      boost(lastReview.wasAfraid,    'afraid');
      boost(lastReview.wasDishonest, 'dishonest');
      boost(lastReview.wasSelfish,   'selfish');
    }
  } catch (_) {
    // Ignore — weighting without today's signals is fine
  }

  // ── Step 3: select reflection ─────────────────────────────────────────────
  return ReflectionService().selectWeighted(
    themeWeights: themeWeights,
    recentKeys: recentKeys,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class Step11MeditationScreen extends HookConsumerWidget {
  const Step11MeditationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditationAsync = ref.watch(step11ReflectionProvider);
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
      body: meditationAsync.when(
        data: (reflection) => reflection == null
            ? _buildEmpty()
            : _buildContent(context, ref, reflection, sessionSaved),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No reflection could be loaded.\n'
          'Check that assets/data/recovery_reflections.csv is present.',
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
    Reflection reflection,
    ValueNotifier<bool> sessionSaved,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Theme badge ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'MEDITATION THEME: ${reflection.theme.toUpperCase()}',
              style: TextStyle(
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 26),

          // ── Quote ──────────────────────────────────────────────────────
          Text(
            reflection.quote,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Divider(thickness: 0.5),
          ),

          // ── Reflection body ────────────────────────────────────────────
          Text(
            'THE REFLECTION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.indigo.shade700,
              letterSpacing: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            reflection.reflection,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),

          // ── Morning prayer ────────────────────────────────────────────
          _buildMorningPrayer(),
          const SizedBox(height: 28),

          // ── Meditation timer ──────────────────────────────────────────
          MeditationTimerWidget(
            accentColor: Colors.indigo.shade700,
            onSave: (seconds) async {
              await ref.read(meditationRepositoryProvider).saveSession(
                    sessionType:     'morning',
                    reflectionTheme: reflection.theme,
                    reflectionKey:   reflection.reflectionKey,
                    durationSeconds: seconds,
                  );
              sessionSaved.value = true;
            },
          ),
          const SizedBox(height: 28),

          // ── Completion button ─────────────────────────────────────────
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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
