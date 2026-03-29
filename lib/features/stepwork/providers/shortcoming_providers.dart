import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/shortcomings_repository.dart';

/// All shortcoming logs, most recent first.
final allShortcomingLogsProvider = StreamProvider<List<ShortcomingLog>>((ref) {
  return ref.watch(shortcomingRepositoryProvider).watchAll();
});

/// Step 4 myPart phrases, filtered to exclude patterns that have already been
/// saved as shortcoming descriptions.  Re-evaluates reactively whenever a
/// shortcoming is logged or deleted (because it watches [allShortcomingLogsProvider]).
final step4PatternsProvider = FutureProvider<List<String>>((ref) async {
  final logs = ref.watch(allShortcomingLogsProvider).valueOrNull ?? [];
  final usedDescriptions =
      logs.map((l) => l.description.trim().toLowerCase()).toSet();

  final allPhrases = await ref
      .read(shortcomingRepositoryProvider)
      .fetchStep4MyPartPhrases();

  return allPhrases
      .where((p) => !usedDescriptions.contains(p.trim().toLowerCase()))
      .toList();
});
