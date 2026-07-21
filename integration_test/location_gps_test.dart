import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:integration_test/integration_test.dart';

/// Verifies CoreLocation / Fused Location returns coordinates when permitted.
///
/// **Run on a real device or simulator** with location services on and
/// permission granted (tap "Allow While Using App" when prompted):
///
/// ```bash
/// flutter test integration_test/location_gps_test.dart \
///   --dart-define=RUN_LOCATION_IT=true
/// ```
///
/// On an iOS Simulator there is no interactive tapper, and `flutter test`
/// reinstalls the app on each run (clearing its TCC grant), so the permission
/// dialog blocks the test. Seed a location and keep re-granting through the
/// reinstall window:
///
/// ```bash
/// DEV=<simulator-udid>
/// xcrun simctl location "$DEV" set 37.7749,-122.4194
/// while :; do
///   xcrun simctl privacy "$DEV" grant location-always \
///     com.fearlessinventory.fearless_inventory 2>/dev/null || true
///   sleep 1
/// done &   # stop this loop once the test finishes
/// flutter test integration_test/location_gps_test.dart \
///   -d "$DEV" --dart-define=RUN_LOCATION_IT=true
/// ```
///
/// CI and default `flutter test` skip this file unless that define is passed,
/// so pipelines stay green without a GPS fixture.
///
/// The gate must be a compile-time define, not [Platform.environment]: the
/// test body runs in the Dart VM on the device, which does not inherit the
/// host shell's environment, so a `RUN_LOCATION_IT=1` prefix never reached it.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const runGpsIntegration = bool.fromEnvironment('RUN_LOCATION_IT');

  testWidgets(
    'GPS returns coordinates when location is permitted',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        fail(
          'Enable location services on the device/simulator and re-run with '
          'RUN_LOCATION_IT=1',
        );
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.whileInUse &&
          perm != LocationPermission.always) {
        fail(
          'Grant "While Using the App" location access and re-run with '
          'RUN_LOCATION_IT=1',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );

      expect(pos.latitude, inInclusiveRange(-90, 90));
      expect(pos.longitude, inInclusiveRange(-180, 180));
      expect(pos.latitude.isFinite, isTrue);
      expect(pos.longitude.isFinite, isTrue);
    },
    skip: !runGpsIntegration,
  );
}
