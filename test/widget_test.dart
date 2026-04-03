import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:fearless_inventory/core/database/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testKey =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  testWidgets('databaseProvider override supplies AppDatabase to UI',
      (WidgetTester tester) async {
    final dir = Directory.systemTemp.createTempSync('fi_widget_');
    final dbFile = File(p.join(dir.path, 'widget.db'));
    final db = AppDatabase.forTesting(dbFile, testKey);
    addTearDown(() async {
      await db.close();
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(() {});
            return db;
          }),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              ref.watch(databaseProvider);
              return const Text('db_ok');
            },
          ),
        ),
      ),
    );

    expect(find.text('db_ok'), findsOneWidget);
  });
}
