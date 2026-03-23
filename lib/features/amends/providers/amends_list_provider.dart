import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../data/repositories/amends_repository.dart';
import '../../../core/database/database.dart';

final amendsListProvider = StreamProvider<List<Amend>>((ref) {
  return ref.watch(amendsRepositoryProvider).watchAll();
});