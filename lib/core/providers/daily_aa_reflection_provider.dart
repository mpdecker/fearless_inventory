import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../literature/preprocessed_literature_store.dart';

/// AA *Daily Reflection* body for today (`MM-DD` in the book), if the PDF
/// was preprocessed (bundled JSON, disk cache, or first-launch extract).
final dailyAaReflectionBodyProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final map = await PreprocessedLiteratureStore.instance
      .loadDailyReflectionBodies();
  final now = DateTime.now();
  final key =
      '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return map[key];
});
