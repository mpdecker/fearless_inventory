import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// The result of geocoding a free-text query via Nominatim.
class GeocodedLocation {
  /// Original query the user typed.
  final String query;

  /// Human-readable place name returned by Nominatim (trimmed to city/state).
  final String displayName;

  final double latitude;
  final double longitude;

  const GeocodedLocation({
    required this.query,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// A resolved lat/lon pair with a human-readable label.
/// Produced by [activeLocationProvider] from either GPS or geocoding.
class ActiveLocation {
  final double latitude;
  final double longitude;

  /// Short label shown in UI, e.g. "Your location" or "Boston, MA".
  final String label;

  /// Whether this came from device GPS (vs geocoded custom query).
  final bool fromGps;

  const ActiveLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.fromGps,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Requests location permission and returns the user's current GPS position,
/// or `null` if unavailable / denied.
final userLocationProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission perm = await Geolocator.checkPermission();
  // Never auto-request the permission dialog — only acquire GPS if the user
  // has already granted it. The GPS button in the UI explicitly calls
  // Geolocator.requestPermission() before refreshing this provider.
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );
  } catch (_) {
    return null;
  }
});

/// Free-text location query entered by the user (zip code or city name).
/// Empty string means "use device GPS".
final locationQueryProvider = StateProvider<String>((ref) => '');

/// Geocoded result for [locationQueryProvider].
/// Returns `null` when the query is empty, blank, or geocoding fails.
final geocodedLocationProvider = FutureProvider<GeocodedLocation?>((ref) async {
  final query = ref.watch(locationQueryProvider).trim();
  if (query.isEmpty) return null;
  return _geocodeNominatim(query);
});

/// Selected distance radius in miles. `null` = show all distances.
final distanceRadiusMiProvider = StateProvider<double?>((ref) => null);

/// The active location used by the Nearby tab — either GPS or geocoded.
///
/// - If [locationQueryProvider] is non-empty → geocodes and uses that.
/// - Otherwise → falls back to device GPS.
/// - Returns `null` when neither source is available.
final activeLocationProvider = FutureProvider<ActiveLocation?>((ref) async {
  final query = ref.watch(locationQueryProvider).trim();

  if (query.isNotEmpty) {
    final geo = await ref.watch(geocodedLocationProvider.future);
    if (geo == null) return null;
    // Use the first two comma-parts of the display name as a short label.
    final parts = geo.displayName.split(',');
    final label = parts
        .take(2)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
    return ActiveLocation(
      latitude: geo.latitude,
      longitude: geo.longitude,
      label: label.isNotEmpty ? label : geo.query,
      fromGps: false,
    );
  }

  // GPS fallback
  final pos = await ref.watch(userLocationProvider.future);
  if (pos == null) return null;
  return ActiveLocation(
    latitude: pos.latitude,
    longitude: pos.longitude,
    label: 'Your location',
    fromGps: true,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Geocoding (Nominatim / OpenStreetMap — free, no API key)
// ─────────────────────────────────────────────────────────────────────────────

Future<GeocodedLocation?> _geocodeNominatim(String query) async {
  try {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'us', // Bias results to the US
      'addressdetails': '0',
    });
    final resp = await http.get(uri, headers: {
      'User-Agent': 'FearlessInventory/1.0 (AA Meeting Locator)',
      'Accept-Language': 'en-US,en',
    }).timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) return null;

    final list = jsonDecode(resp.body) as List<dynamic>;
    if (list.isEmpty) return null;

    final place = list.first as Map<String, dynamic>;
    return GeocodedLocation(
      query: query,
      displayName: (place['display_name'] as String? ?? query),
      latitude: double.parse(place['lat'] as String),
      longitude: double.parse(place['lon'] as String),
    );
  } catch (_) {
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────────────────────────────────────

/// Haversine great-circle distance in **kilometres**.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

/// Human-readable distance string (imperial miles).
String formatDistance(double km) {
  final miles = km * 0.621371;
  if (miles < 0.1) return '< 0.1 mi';
  if (miles < 10) return '${miles.toStringAsFixed(1)} mi';
  return '${miles.round()} mi';
}

/// Convert miles to kilometres.
double miToKm(double miles) => miles / 0.621371;
