import 'dart:math';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class Reflection {
  final String theme;
  final String quote;
  final String reflection;

  Reflection({required this.theme, required this.quote, required this.reflection});
}

class ReflectionService {
  // Mapping shortcomings/signals to CSV themes
  static const Map<String, List<String>> _signalToThemes = {
    'resentful': ['acceptance', 'letting go', 'compassion', 'patience'],
    'afraid': ['courage', 'trust', 'faith', 'resilience'],
    'dishonest': ['honesty', 'self-awareness', 'reflection'],
    'selfish': ['service', 'community', 'humility', 'growth'],
  };

  /// Alias for [getThematicReflection] — resolves calls from step_11_meditation_screen.
  Future<Reflection?> getReflectionForSignals(List<String> activeSignals) =>
      getThematicReflection(activeSignals);

  Future<Reflection?> getThematicReflection(List<String> activeSignals) async {
    final rawData = await rootBundle.loadString('assets/data/recovery_reflections.csv');
    List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
    rows.removeAt(0); // Header

    List<String> targetThemes = [];
    for (var signal in activeSignals) {
      targetThemes.addAll(_signalToThemes[signal.toLowerCase()] ?? []);
    }

    // Default themes if no signals are present
    if (targetThemes.isEmpty) {
      targetThemes = ['growth', 'mindfulness', 'balance', 'willingness', 'hope'];
    }

    final matchingRows = rows.where((row) => targetThemes.contains(row[1])).toList();
    if (matchingRows.isEmpty) return null;

    final randomRow = matchingRows[Random().nextInt(matchingRows.length)];
    
    return Reflection(
      theme: randomRow[1].toString(),
      quote: randomRow[2].toString(),
      reflection: randomRow[3].toString(),
    );
  }
}