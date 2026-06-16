import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/key_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('KeyService', () {
    test('getOrCreateDatabaseKey generates a 32-byte hex key on first use', () async {
      final key = await KeyService.getOrCreateDatabaseKey();
      expect(key, hasLength(64));
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(key), isTrue);
    });

    test('getOrCreateDatabaseKey returns the same key on subsequent calls', () async {
      final a = await KeyService.getOrCreateDatabaseKey();
      final b = await KeyService.getOrCreateDatabaseKey();
      expect(b, a);
    });

    test('getOrCreateDatabaseKey respects existing mock storage value', () async {
      const existing =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      FlutterSecureStorage.setMockInitialValues({
        KeyService.storageKey: existing,
      });
      expect(await KeyService.getOrCreateDatabaseKey(), existing);
    });

    test('clearStaleEncryptionKeyIfDatabaseMissing keeps key when DB file exists',
        () async {
      const existing =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      FlutterSecureStorage.setMockInitialValues({KeyService.storageKey: existing});
      final tmp = Directory.systemTemp.createTempSync('fi_key_test');
      final db = File('${tmp.path}/fearless_inventory.db');
      await db.writeAsString('x');
      addTearDown(() => tmp.deleteSync(recursive: true));

      await KeyService.clearStaleEncryptionKeyIfDatabaseMissing(db);
      expect(await KeyService.getOrCreateDatabaseKey(), existing);
    });

    test(
        'clearStaleEncryptionKeyIfDatabaseMissing removes key when DB is absent',
        () async {
      const existing =
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
      FlutterSecureStorage.setMockInitialValues({KeyService.storageKey: existing});
      final tmp = Directory.systemTemp.createTempSync('fi_key_test2');
      final db = File('${tmp.path}/missing.db');
      addTearDown(() => tmp.deleteSync(recursive: true));

      await KeyService.clearStaleEncryptionKeyIfDatabaseMissing(db);
      final next = await KeyService.getOrCreateDatabaseKey();
      expect(next, isNot(existing));
      expect(next, hasLength(64));
    });
  });
}
