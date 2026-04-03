import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:fearless_inventory/core/services/key_service.dart';

/// **Destructive:** deletes the real app database file
/// (`fearless_inventory.db` in application documents) and rotates the
/// encryption key in Keychain / Keystore.
///
/// Only run on a **disposable simulator** or install you can wipe:
/// `flutter test integration_test/keychain_reinstall_test.dart`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('stale encryption key cleared when production DB file is gone',
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
}
