import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/services/key_service.dart';

/// Run on a simulator or device (Keychain / Keystore + path_provider):
/// `flutter test integration_test/database_flow_test.dart`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'after DB file removed, stale encryption key is cleared and replaced',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    final dir = await getApplicationDocumentsDirectory();
    final prodDb = File(
      p.join(dir.path, KeyService.productionDatabaseFileName),
    );
    if (!await prodDb.exists()) {
      await prodDb.create(recursive: true);
    }

    final keyBefore = await KeyService.getOrCreateDatabaseKey();
    expect(keyBefore, hasLength(64));

    if (await prodDb.exists()) {
      await prodDb.delete();
    }
    await KeyService.clearStaleEncryptionKeyIfDatabaseMissing(prodDb);

    final keyAfter = await KeyService.getOrCreateDatabaseKey();
    expect(keyAfter, isNot(keyBefore));
    expect(keyAfter, hasLength(64));
  });

  testWidgets('KeyService key is stable; encrypted DB persists resentment',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    final key1 = await KeyService.getOrCreateDatabaseKey();
    final key2 = await KeyService.getOrCreateDatabaseKey();
    expect(key2, key1);
    expect(key1, hasLength(64));

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'integration_test_fi.db'));
    if (await file.exists()) {
      await file.delete();
    }

    var db = AppDatabase.forTesting(file, key1);
    final now = DateTime.now();
    await db.into(db.resentments).insert(ResentmentsCompanion.insert(
          person: 'Integration Person',
          cause: 'cause',
          affects: 'affects',
          myPart: 'part',
          createdAt: now,
        ));

    var rows = await db.select(db.resentments).get();
    expect(rows, hasLength(1));
    expect(rows.single.person, 'Integration Person');
    await db.close();

    db = AppDatabase.forTesting(file, key1);
    rows = await db.select(db.resentments).get();
    expect(rows, hasLength(1));
    expect(rows.single.person, 'Integration Person');
    await db.close();

    if (await file.exists()) {
      await file.delete();
    }
  });
}
