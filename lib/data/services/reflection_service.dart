import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class Reflection {
  final String theme;
  final String quote;
  final String reflection;

  /// Stable fingerprint: first 80 characters of [quote].
  /// Stored in MeditationSessions.reflectionKey so the recency algorithm
  /// can penalise passages that were surfaced very recently.
  final String reflectionKey;

  Reflection({
    required this.theme,
    required this.quote,
    required this.reflection,
  }) : reflectionKey = quote.length > 80 ? quote.substring(0, 80) : quote;
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class ReflectionService {
  // Step-10 signal → theme mapping (shared with MeditationRepository)
  static const Map<String, List<String>> signalToThemes = {
    'resentful': ['acceptance', 'letting go', 'compassion', 'patience'],
    'afraid':    ['courage', 'trust', 'faith', 'resilience'],
    'dishonest': ['honesty', 'self-awareness', 'reflection'],
    'selfish':   ['service', 'community', 'humility', 'growth'],
  };

  /// All 22 themes present in recovery_reflections.json.
  /// Using the full set as the default means new users (no Step-10 history)
  /// get variety across the entire dataset rather than a narrow subset.
  static const List<String> _defaultThemes = [
    'acceptance', 'balance',        'community',       'compassion',
    'courage',    'faith',          'gratitude',        'growth',
    'honesty',    'hope',           'humility',         'letting go',
    'mindfulness','patience',       'perseverance',     'reflection',
    'resilience', 'responsibility', 'self-awareness',   'service',
    'trust',      'willingness',
  ];

  static const List<String> _bedtimeCalmThemes = [
    'letting go', 'trust', 'gratitude', 'balance',  'mindfulness',
    'faith',      'compassion', 'patience', 'acceptance', 'humility',
    'reflection', 'hope',
  ];

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Weighted, recency-aware selection.
  ///
  /// [themeWeights]  Maps theme names to relative importance (higher = more
  ///                 likely). Built from 30-day Step-10 signal frequencies
  ///                 plus a per-session boost for today's active signals.
  ///
  /// [recentKeys]    Maps reflectionKey → most-recent completedAt.
  ///                 Recency penalty:
  ///                   < 2 days  → ×0.05
  ///                   < 5 days  → ×0.30
  ///                   < 10 days → ×0.70
  ///                   ≥ 10 days → full weight
  ///
  /// [extraThemes]   Additional themes boosted to weight 1.0 each
  ///                 (used for the bedtime calm-theme bias).
  Future<Reflection?> selectWeighted({
    required Map<String, double> themeWeights,
    required Map<String, DateTime> recentKeys,
    List<String> extraThemes = const [],
  }) async {
    final rows = await _loadRows();
    if (rows.isEmpty) return null;

    // Build the set of target themes
    final targetThemes = <String>{
      ...themeWeights.keys,
      ...extraThemes,
    };
    if (targetThemes.isEmpty) targetThemes.addAll(_defaultThemes);

    // Stage 1: theme-filtered candidates
    var candidates =
        rows.where((r) => targetThemes.contains(r['theme'])).toList();

    // Stage 2 fallback: if theme-filtering yields nothing, use all rows
    // so the screen always receives a reflection.
    if (candidates.isEmpty) candidates = rows;
    if (candidates.isEmpty) return null;

    // Build weight list
    final weights = <double>[];
    for (final row in candidates) {
      final theme = row['theme'] as String;
      final quote = row['quote'] as String;
      final key   = quote.length > 80 ? quote.substring(0, 80) : quote;

      // Base weight: explicit weight from Step-10 history, or 1.0
      double w = themeWeights[theme] ?? 1.0;

      // Recency penalty
      if (recentKeys.containsKey(key)) {
        final ageDays = DateTime.now().difference(recentKeys[key]!).inDays;
        if (ageDays < 2) {
          w *= 0.05;
        } else if (ageDays < 5) {
          w *= 0.30;
        } else if (ageDays < 10) {
          w *= 0.70;
        }
        // ≥ 10 days: full weight restored
      }

      weights.add(w.clamp(0, double.infinity));
    }

    // Weighted random pick
    final total = weights.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      return _toReflection(candidates[Random().nextInt(candidates.length)]);
    }

    final dart = Random().nextDouble() * total;
    double cumulative = 0;
    for (int i = 0; i < candidates.length; i++) {
      cumulative += weights[i];
      if (dart <= cumulative) return _toReflection(candidates[i]);
    }
    return _toReflection(candidates.last); // floating-point edge case
  }

  /// Convenience: morning meditation seeded from raw signal names.
  Future<Reflection?> getReflectionForSignals(
    List<String> activeSignals, {
    Map<String, DateTime> recentKeys = const {},
  }) =>
      selectWeighted(
        themeWeights: _signalsToWeights(activeSignals),
        recentKeys: recentKeys,
      );

  /// Convenience: bedtime meditation biased toward calm/rest themes.
  Future<Reflection?> getBedtimeReflection(
    List<String> activeSignals, {
    Map<String, DateTime> recentKeys = const {},
  }) =>
      selectWeighted(
        themeWeights: _signalsToWeights(activeSignals),
        recentKeys: recentKeys,
        extraThemes: _bedtimeCalmThemes,
      );

  // ── Internal helpers ────────────────────────────────────────────────────────

  /// Loads the reflections JSON asset and returns it as a list of maps.
  /// Each map has keys: 'theme', 'quote', 'reflection'.
  Future<List<Map<String, dynamic>>> _loadRows() async {
    final raw = await rootBundle
        .loadString('assets/data/recovery_reflections.json');
    final decoded = json.decode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .where((r) =>
            r['theme'] is String &&
            r['quote'] is String &&
            r['reflection'] is String)
        .toList();
  }

  Reflection _toReflection(Map<String, dynamic> row) => Reflection(
        theme:      row['theme']      as String,
        quote:      row['quote']      as String,
        reflection: row['reflection'] as String,
      );

  static Map<String, double> _signalsToWeights(List<String> signals) {
    final weights = <String, double>{};
    for (final signal in signals) {
      for (final theme in signalToThemes[signal.toLowerCase()] ?? <String>[]) {
        weights[theme] = (weights[theme] ?? 0) + 1.0;
      }
    }
    return weights;
  }
}
