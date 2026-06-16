import 'package:fearless_inventory/features/meetings/map_launch_uri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appleMapsUriForCoordinates', () {
    test('uses ll and optional q', () {
      final u = appleMapsUriForCoordinates(
        latitude: 42.355433,
        longitude: -71.060511,
        placeName: 'Boston',
      );
      expect(u.scheme, 'https');
      expect(u.host, 'maps.apple.com');
      expect(u.queryParameters['ll'], '42.355433,-71.060511');
      expect(u.queryParameters['q'], 'Boston');
    });

    test('omits q when placeName is null', () {
      final u = appleMapsUriForCoordinates(
        latitude: 1.0,
        longitude: 2.0,
      );
      expect(u.queryParameters['ll'], '1.0,2.0');
      expect(u.queryParameters.containsKey('q'), isFalse);
    });
  });

  group('appleMapsUriForQuery', () {
    test('encodes search query', () {
      final u = appleMapsUriForQuery('123 Main St, Boston MA');
      expect(u.host, 'maps.apple.com');
      expect(u.queryParameters['q'], '123 Main St, Boston MA');
    });
  });

  group('appleMapsUriFromGeoUri', () {
    test('converts geo: with coordinates in path and label in q', () {
      final geo = Uri.parse(
        'geo:42.355433,-71.060511?q=42.355433,-71.060511(Boston%20Meeting)',
      );
      final apple = appleMapsUriFromGeoUri(geo);
      expect(apple, isNotNull);
      expect(apple!.queryParameters['ll'], '42.355433,-71.060511');
      expect(apple.queryParameters['q'], 'Boston Meeting');
    });

    test('returns null for non-geo scheme', () {
      expect(
        appleMapsUriFromGeoUri(Uri.parse('https://example.com')),
        isNull,
      );
    });

    test('reads coordinates from q when path is 0,0', () {
      final geo = Uri.parse('geo:0,0?q=40.7128,-74.0061');
      final apple = appleMapsUriFromGeoUri(geo);
      expect(apple, isNotNull);
      expect(apple!.queryParameters['ll'], '40.7128,-74.0061');
    });
  });

  group('parseLeadingLatLng', () {
    test('parses simple pair', () {
      expect(parseLeadingLatLng('40.5,-73.2'), (40.5, -73.2));
    });

    test('parses pair before parenthetical', () {
      expect(
        parseLeadingLatLng('40.5,-73.2(Foo)'),
        (40.5, -73.2),
      );
    });
  });

  group('placeNameFromGeoQueryParameter', () {
    test('decodes label in parentheses', () {
      expect(
        placeNameFromGeoQueryParameter('40,-74(My%20Place)'),
        'My Place',
      );
    });
  });
}
