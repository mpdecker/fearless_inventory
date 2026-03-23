import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../data/repositories/resentment_repository.dart';

// This provider manages the stream of resentments from the database
final resentmentsStreamProvider = StreamProvider<List<Resentment>>((ref) {
  return ref.watch(resentmentRepositoryProvider).watchAllResentments();
});