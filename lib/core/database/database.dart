import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/amends_type.dart';

part 'database.g.dart';

// Table definitions for Steps 4, 6, 7 remain unchanged for brevity...
class Resentments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get person => text().withLength(min: 1, max: 200)();
  TextColumn get cause => text()();
  TextColumn get affects => text()(); 
  TextColumn get myPart => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class Fears extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subject => text().withLength(min: 1, max: 200)(); 
  TextColumn get why => text()();                               
  TextColumn get myPart => text()();                            
  DateTimeColumn get createdAt => dateTime()();
}

class Harms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get person => text().withLength(min: 1, max: 200)();
  TextColumn get conduct => text()();
  TextColumn get myPart => text()();
  TextColumn get amendsPlan => text().nullable()();
  BoolColumn get isAmendsDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateAmendsDone => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class DailyReviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get wasResentful => boolean().withDefault(const Constant(false))();
  BoolColumn get wasSelfish => boolean().withDefault(const Constant(false))();
  BoolColumn get wasDishonest => boolean().withDefault(const Constant(false))();
  BoolColumn get wasAfraid => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get gratitude => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Amends extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get harmId => integer()
      .nullable()
      .references(Harms, #id, onDelete: KeyAction.cascade)();
  TextColumn get person => text().withLength(min: 1, max: 200)();
  
  // UPDATED: Nullable for Step 8 workflow
  IntColumn get amendsType => intEnum<AmendsType>().nullable()();
  TextColumn get plan => text().nullable()();
  
  IntColumn get priority => integer().withDefault(const Constant(2))();
  
  // UPDATED: Default status is now 'step8'
  TextColumn get status => text().withDefault(const Constant('step8'))();
  
  // UPDATED: Nullable for Step 8 workflow
  DateTimeColumn get datePlanned => dateTime().nullable()();
  DateTimeColumn get dateCompleted => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Defects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get category => text().nullable()(); 
  BoolColumn get isReady => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class ShortcomingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  DateTimeColumn get dateObserved => dateTime()();
  IntColumn get relatedReviewId => integer().nullable().references(DailyReviews, #id)();
}

@DriftDatabase(tables: [Resentments, Fears, Harms, DailyReviews, Amends, Defects, ShortcomingLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) async => m.createAll());
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fearless_inventory.db'));
    return NativeDatabase.createInBackground(file, setup: (db) {
        db.execute('PRAGMA key = "fearless2026";'); 
        db.execute('PRAGMA cipher = "sqlcipher";');
        db.execute('PRAGMA legacy = 4;');
      },
    );
  });
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});