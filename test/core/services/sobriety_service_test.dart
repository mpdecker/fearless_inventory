import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/sobriety_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('SobrietyService', () {
    test('reads legacy sobriety_date_v1 until migrated', () async {
      FlutterSecureStorage.setMockInitialValues({
        'sobriety_date_v1': '2024-06-15',
      });
      final d = await SobrietyService.getSobrietyDate();
      expect(d, DateTime(2024, 6, 15));
    });

    test('setSobrietyDate writes fearless_sobriety_date and drops legacy',
        () async {
      FlutterSecureStorage.setMockInitialValues({
        'sobriety_date_v1': '2020-01-01',
      });
      await SobrietyService.setSobrietyDate(DateTime(2025, 3, 1));

      expect(
        await SobrietyService.getSobrietyDate(),
        DateTime(2025, 3, 1),
      );
    });
  });
}
