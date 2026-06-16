import 'dart:convert';

import 'package:fearless_inventory/features/meetings/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('geocodeNominatim returns result for Boston, MA', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'nominatim.openstreetmap.org');
      expect(request.url.path, '/search');
      expect(request.url.queryParameters['q'], 'Boston, MA');

      final body = jsonEncode([
        {
          'lat': '42.355433',
          'lon': '-71.060511',
          'display_name':
              'Boston, Suffolk County, Massachusetts, United States',
        }
      ]);
      return http.Response(body, 200);
    });

    final result = await geocodeNominatim('Boston, MA', httpClient: client);

    expect(result, isNotNull);
    expect(result!.query, 'Boston, MA');
    expect(result.latitude, closeTo(42.355433, 1e-6));
    expect(result.longitude, closeTo(-71.060511, 1e-6));
    expect(
      result.displayName,
      contains('Boston'),
    );
  });

  test('geocodeNominatim returns result for US zip code', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters['q'], '02108');

      final body = jsonEncode([
        {
          'lat': '42.355433',
          'lon': '-71.060511',
          'display_name': '02108, Boston, Massachusetts, United States',
        }
      ]);
      return http.Response(body, 200);
    });

    final result = await geocodeNominatim('02108', httpClient: client);
    expect(result, isNotNull);
    expect(result!.latitude, closeTo(42.355433, 1e-6));
  });

  test('geocodeNominatim returns null on empty API list', () async {
    final client = MockClient((request) async {
      return http.Response('[]', 200);
    });

    final result = await geocodeNominatim('Nowhereville XYZ', httpClient: client);
    expect(result, isNull);
  });
}
