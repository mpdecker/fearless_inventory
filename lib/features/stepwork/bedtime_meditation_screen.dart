import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/database.dart';
import '../../data/services/reflection_service.dart';
import '../../data/repositories/meditation_repository.dart';
import '../../core/widgets/meditation_timer.dart';
import 'evening_transition_screen.dart';
import '../review/daily_review_screen.dart';
import '../review/review_type.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Evening Step 11: reflection biased toward trust, letting go, gratitude,
/// and rest — while still honouring today's active Step-10 signals.
final bedtimeReflectionProvider =
    FutureProvider.autoDispose<Reflection?>((ref) async {
  final db = ref.read(databaseProvider);

  // ── Step 1: gather weights & recency map ─────────────────────────────────
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
    // DB not fully migrated yet — continue with empty maps
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
    // Ignore — evening calm themes still apply
  }

  // ── Step 3: select with evening calm bias ─────────────────────────────────
  // These themes are added with a base weight of 1.0 each so they always have
  // some presence, even with no Step-10 signals.
  const bedtimeCalmThemes = [
    'letting go', 'trust', 'gratitude', 'balance', 'mindfulness',
    'faith', 'compassion', 'patience', 'acceptance', 'humility',
    'reflection', 'hope',
  ];

  return ReflectionService().selectWeighted(
    themeWeights: themeWeights,
    recentKeys: recentKeys,
    extraThemes: bedtimeCalmThemes,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class BedtimeMeditationScreen extends HookConsumerWidget {
  const BedtimeMeditationScreen({super.key});

  static const Color _nightBg      = Color(0xFF12121F);
  static const Color _nightSurface = Color(0xFF1E1E2E);
  static const Color _moonGold     = Color(0xFFE8DCC8);
  static const Color _timerAccent  = Color(0xFF7986CB); // indigo-300 (readable on dark)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditationAsync = ref.watch(bedtimeReflectionProvider);
    final sessionSaved    = useState(false);

    return Scaffold(
      backgroundColor: _nightBg,
      appBar: AppBar(
        title: const Text('Before Bed Meditation'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _nightBg,
        foregroundColor: _moonGold,
      ),
      body: meditationAsync.when(
        data: (reflection) => reflection == null
            ? _buildEmpty()
            : _buildContent(context, ref, reflection, sessionSaved),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFB0B0C8)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.white70)),
        ),
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
          style: TextStyle(color: Colors.white38, fontSize: 15, height: 1.5),
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
          // ── Header ─────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.nightlight_round,
                  color: Colors.amber.shade200, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Set down the day.  Rest in willingness.',
                  style: TextStyle(
                    color: Colors.blueGrey.shade100,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Theme badge ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _nightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'EVENING THEME: ${reflection.theme.toUpperCase()}',
              style: TextStyle(
                color: Colors.indigo.shade100,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Quote ──────────────────────────────────────────────────────
          Text(
            reflection.quote,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: Color(0xFFE0E0F0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Divider(color: Colors.white.withValues(alpha: 0.12)),
          ),

          // ── Reflection body ────────────────────────────────────────────
          Text(
            'THE REFLECTION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.indigo.shade200,
              letterSpacing: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            reflection.reflection,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: Color(0xFFB0B0C8),
            ),
          ),
          const SizedBox(height: 32),

          // ── Evening prayer ─────────────────────────────────────────────
          _buildEveningPrayer(),
          const SizedBox(height: 20),

          // ── Nightly 10th Step review ───────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const DailyReviewScreen(reviewType: ReviewType.nightly),
              ),
            ),
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Nightly 10th Step'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: Colors.indigo.shade200,
              side: BorderSide(color: Colors.indigo.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 28),

          // ── Meditation timer (dark-mode palette) ──────────────────────
          MeditationTimerWidget(
            accentColor: _timerAccent,
            onSave: (seconds) async {
              await ref.read(meditationRepositoryProvider).saveSession(
                    sessionType:     'evening',
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
            onPressed: () => Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const EveningTransitionScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 700),
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              sessionSaved.value ? 'Session saved — good night' : 'Good night',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildEveningPrayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _nightSurface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A moment to close the day',
            style: TextStyle(
              color: Colors.indigo.shade100,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"We ask especially for freedom from self-will, and are careful '
            'to make no request for ourselves only.  We may ask for ourselves, '
            'however, if others will be helped.  We are careful never to pray '
            'for our own selfish ends."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: _moonGold.withValues(alpha: 0.9),
              height: 1.45,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
