/// Apple Maps URLs for [url_launcher] on iOS. `geo:` is not handled by iOS;
/// use these instead.
Uri appleMapsUriForCoordinates({
  required double latitude,
  required double longitude,
  String? placeName,
}) {
  final ll = '$latitude,$longitude';
  final params = <String, String>{'ll': ll};
  if (placeName != null && placeName.isNotEmpty) {
    params['q'] = placeName;
  }
  return Uri.https('maps.apple.com', '/', params);
}

/// Text search (address / venue) in Apple Maps.
Uri appleMapsUriForQuery(String query) {
  return Uri.https('maps.apple.com', '/', {'q': query});
}

/// Parses `lat,lng` at the start of [s] (allows a trailing `(label)` in [q]-style strings).
(double lat, double lng)? parseLeadingLatLng(String s) {
  final trimmed = s.trim();
  final m = RegExp(r'^(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)')
      .firstMatch(trimmed);
  if (m == null) return null;
  return (double.parse(m.group(1)!), double.parse(m.group(2)!));
}

/// Optional place name inside parentheses, e.g. `40,-74(My%20Place)`.
String? placeNameFromGeoQueryParameter(String? q) {
  if (q == null) return null;
  final open = q.indexOf('(');
  final close = q.indexOf(')');
  if (open == -1 || close <= open) return null;
  return Uri.decodeComponent(q.substring(open + 1, close));
}

/// Reads coordinates from a `geo:` URI (path or `q=` when path is `0,0`).
(double lat, double lng)? latLngFromGeoUri(Uri geo) {
  if (geo.scheme != 'geo') return null;

  final pathPair = parseLeadingLatLng(geo.path);
  if (pathPair != null && (pathPair.$1 != 0 || pathPair.$2 != 0)) {
    return pathPair;
  }

  final q = geo.queryParameters['q'];
  if (q != null) {
    final head = q.split('(').first;
    final fromQ = parseLeadingLatLng(head);
    if (fromQ != null) return fromQ;
  }

  return pathPair;
}

/// Converts a `geo:` URI (e.g. from Android-style map links) to an Apple Maps
/// https URL suitable for iOS.
Uri? appleMapsUriFromGeoUri(Uri geo) {
  if (geo.scheme != 'geo') return null;
  final coords = latLngFromGeoUri(geo);
  if (coords == null) return null;

  final label = placeNameFromGeoQueryParameter(geo.queryParameters['q']);
  return appleMapsUriForCoordinates(
    latitude: coords.$1,
    longitude: coords.$2,
    placeName: label,
  );
}
