import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

/// Aggregate repository providing unified access to the Step 4 inventory tables:
/// Resentments, Fears, and Harms. Used by harm_list_screen and settings_screen
/// for combined data access and export.
final inventoryRepositoryProvider =
    Provider((ref) => InventoryRepository(ref));

class InventoryRepository {
  final Ref _ref;
  InventoryRepository(this._ref);

  AppDatabase get _db => _ref.read(databaseProvider);

  // --- Resentments ---
  Stream<List<Resentment>> watchResentments() =>
      _db.select(_db.resentments).watch();

  // --- Fears ---
  Stream<List<Fear>> watchFears() => _db.select(_db.fears).watch();

  // --- Harms ---
  Stream<List<Harm>> watchHarms() => _db.select(_db.harms).watch();
}
