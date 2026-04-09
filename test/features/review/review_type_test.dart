import 'package:flutter_test/flutter_test.dart';
import 'package:fearless_inventory/features/review/review_type.dart';

void main() {
  group('ReviewType.dbValue', () {
    test('morning → "morning"',    () => expect(ReviewType.morning.dbValue,   'morning'));
    test('spotCheck → "spot_check"', () => expect(ReviewType.spotCheck.dbValue, 'spot_check'));
    test('nightly → "nightly"',    () => expect(ReviewType.nightly.dbValue,   'nightly'));
  });

  group('ReviewType.displayTitle', () {
    test('morning → "Morning 10th Step"',  () => expect(ReviewType.morning.displayTitle,   'Morning 10th Step'));
    test('spotCheck → "Spot Check"',        () => expect(ReviewType.spotCheck.displayTitle, 'Spot Check'));
    test('nightly → "Nightly 10th Step"',  () => expect(ReviewType.nightly.displayTitle,   'Nightly 10th Step'));
  });

  group('ReviewType.fromDb', () {
    test('"morning" → morning',      () => expect(ReviewType.fromDb('morning'),    ReviewType.morning));
    test('"spot_check" → spotCheck', () => expect(ReviewType.fromDb('spot_check'), ReviewType.spotCheck));
    test('"nightly" → nightly',      () => expect(ReviewType.fromDb('nightly'),    ReviewType.nightly));
    test('null → nightly (default)', () => expect(ReviewType.fromDb(null),         ReviewType.nightly));
    test('unknown string → nightly', () => expect(ReviewType.fromDb('evening'),    ReviewType.nightly));
    test('empty string → nightly',   () => expect(ReviewType.fromDb(''),           ReviewType.nightly));
  });

  group('round-trip', () {
    for (final type in ReviewType.values) {
      test('${type.name} survives dbValue → fromDb', () {
        expect(ReviewType.fromDb(type.dbValue), type);
      });
    }
  });
}
