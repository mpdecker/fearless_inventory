import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';
import 'package:fearless_inventory/core/services/sobriety_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase.testing(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('SobrietyService', () {
    test('returns null when nothing has ever been set', () async {
      expect(await SobrietyService.getSobrietyDate(db), isNull);
    });

    test('setSobrietyDate persists and getSobrietyDate reads it back',
        () async {
      await SobrietyService.setSobrietyDate(db, DateTime(2025, 3, 1));

      expect(
        await SobrietyService.getSobrietyDate(db),
        DateTime(2025, 3, 1),
      );
    });

    test('clear removes the stored date', () async {
      await SobrietyService.setSobrietyDate(db, DateTime(2025, 3, 1));
      await SobrietyService.clear(db);

      expect(await SobrietyService.getSobrietyDate(db), isNull);
    });

    test('migrates a legacy appSecureStorage value into the database on first read',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        'fearless_sobriety_date': '2024-06-15',
      });

      final migrated = await SobrietyService.getSobrietyDate(db);
      expect(migrated, DateTime(2024, 6, 15));

      // The value now lives in the database — a fresh read (with the
      // legacy key gone) still returns it.
      const storage = FlutterSecureStorage();
      expect(await storage.read(key: 'fearless_sobriety_date'), isNull);
      expect(await SobrietyService.getSobrietyDate(db), DateTime(2024, 6, 15));
    });

    test('migrates the older sobriety_date_v1 key when the newer one is absent',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        'sobriety_date_v1': '2020-01-01',
      });

      expect(await SobrietyService.getSobrietyDate(db), DateTime(2020, 1, 1));
    });

    test('a value already in the database takes priority over any legacy key',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        'fearless_sobriety_date': '2020-01-01',
      });
      await SobrietyService.setSobrietyDate(db, DateTime(2025, 3, 1));

      expect(await SobrietyService.getSobrietyDate(db), DateTime(2025, 3, 1));
    });
  });
}
