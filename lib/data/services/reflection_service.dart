import 'dart:math';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

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
  // Step-10 signal → CSV theme mapping (shared with MeditationRepository)
  static const Map<String, List<String>> signalToThemes = {
    'resentful': ['acceptance', 'letting go', 'compassion', 'patience'],
    'afraid':    ['courage', 'trust', 'faith', 'resilience'],
    'dishonest': ['honesty', 'self-awareness', 'reflection'],
    'selfish':   ['service', 'community', 'humility', 'growth'],
  };

  /// All 22 themes present in recovery_reflections.csv.
  ///
  /// Using the full set as the default means new users (no Step-10 history)
  /// get variety across the entire CSV rather than just 5 themes.
  static const List<String> _defaultThemes = [
    'acceptance', 'balance',    'community',  'compassion',
    'courage',    'faith',      'gratitude',  'growth',
    'honesty',    'hope',       'humility',   'letting go',
    'mindfulness','patience',   'perseverance','reflection',
    'resilience', 'responsibility','self-awareness','service',
    'trust',      'willingness',
  ];

  static const List<String> _bedtimeCalmThemes = [
    'letting go', 'trust', 'gratitude', 'balance', 'mindfulness',
    'faith', 'compassion', 'patience', 'acceptance', 'humility',
    'reflection', 'hope',
  ];

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Weighted, recency-aware selection.
  ///
  /// [themeWeights]  Maps CSV theme names to relative importance.
  ///                 Higher values make a theme more likely to be picked.
  ///                 Typically built from 30-day Step-10 signal frequencies
  ///                 plus a per-session boost for today's active signals.
  ///
  /// [recentKeys]    Maps reflectionKey → most-recent completedAt.
  ///                 Used to apply a recency penalty:
  ///                   < 2 days  → ×0.05
  ///                   < 5 days  → ×0.30
  ///                   < 10 days → ×0.70
  ///                   ≥ 10 days → ×1.00 (full weight restored)
  ///
  /// [extraThemes]   Extra themes added with a base weight of 1.0 each
  ///                 (used for the bedtime calm-theme bias).
  Future<Reflection?> selectWeighted({
    required Map<String, double> themeWeights,
    required Map<String, DateTime> recentKeys,
    List<String> extraThemes = const [],
  }) async {
    final rows = await _loadRows();

    // Gather target themes
    final targetThemes = <String>{
      ...themeWeights.keys,
      ...extraThemes,
    };
    if (targetThemes.isEmpty) targetThemes.addAll(_defaultThemes);

    // Stage 1: rows whose theme is in the target set.
    var candidates =
        rows.where((r) => targetThemes.contains(r[1].toString())).toList();

    // Stage 2 fallback: if theme-filtering yields nothing (e.g. CSV parsed
    // differently on this device / Flutter version), use ALL valid rows so
    // the screen always receives a reflection instead of showing empty state.
    if (candidates.isEmpty) {
      candidates = rows.where((r) => r.length >= 4).toList();
    }

    // Only truly empty if the CSV itself is missing or unparseable.
    if (candidates.isEmpty) return null;

    // Build weight list
    final weights = <double>[];
    for (final row in candidates) {
      final theme = row[1].toString();
      final quote = row[2].toString();
      final key   = quote.length > 80 ? quote.substring(0, 80) : quote;

      // Base: explicit weight, or 1.0 for extraTheme-only themes
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
        // ≥ 10 days: full weight, no penalty
      }

      weights.add(w.clamp(0, double.infinity));
    }

    // Weighted random pick via cumulative distribution
    final total = weights.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      // All weights zeroed — fallback to uniform random
      return _toReflection(candidates[Random().nextInt(candidates.length)]);
    }

    final dart = Random().nextDouble() * total;
    double cumulative = 0;
    for (int i = 0; i < candidates.length; i++) {
      cumulative += weights[i];
      if (dart <= cumulative) return _toReflection(candidates[i]);
    }
    return _toReflection(candidates.last); // floating-point edge
  }

  /// Convenience: morning meditation seeded from raw signal names.
  /// Delegates to [selectWeighted] with a flat weight of 1.0 per signal theme.
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

  Future<List<List<dynamic>>> _loadRows() async {
    final raw =
        await rootBundle.loadString('assets/data/recovery_reflections.csv');
    final all = const CsvToListConverter().convert(raw);
    // Use sublist instead of removeAt so we never mutate a potentially
    // fixed-length list (csv 6.x may return non-growable collections).
    // Filter out the header row (index 0) and any incomplete rows — the CSV
    // file ends with a trailing newline which the parser returns as a
    // zero-length or single-field row; those would throw RangeError on r[1].
    if (all.length <= 1) return const [];
    return all.sublist(1).where((r) => r.length >= 4).toList();
  }

  Reflection _toReflection(List<dynamic> row) => Reflection(
        theme:      row[1].toString(),
        quote:      row[2].toString(),
        reflection: row[3].toString(),
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
