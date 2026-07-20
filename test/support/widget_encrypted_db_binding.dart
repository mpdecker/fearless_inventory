import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/database/database.dart';

import '../data/repositories/repository_test_support.dart';

/// Helpers for combining [testWidgets], encrypted Drift databases, and
/// `dart:io` temp directories.
///
/// **Why this file exists:** `testWidgets` runs the body in the binding's
/// *fake-async* zone. Awaiting [Directory.createTemp] and opening SQLite from
/// that zone can wedge the test isolate (symptoms: 10-minute timeout,
/// `_RawReceivePort._handleMessage` in the stack). Opening the database inside
/// [WidgetTester.runAsync] runs that work on the real async zone instead.
///
/// **Drift + Riverpod teardown:** cancelling a `watch()` schedules a
/// zero-duration timer. The test binding asserts no pending timers when the
/// test body ends, so pop the pushed route (dismissing stream providers) and
/// advance the fake clock slightly before replacing the tree — see
/// [resetWidgetBindingAfterDriftStreams].

Future<({Directory dir, File dbFile, AppDatabase db})>
    openTempEncryptedDbForWidgetTest(
  WidgetTester tester,
  String tempPrefix,
) async {
  late ({Directory dir, File dbFile, AppDatabase db}) out;
  await tester.runAsync(() async {
    out = await openTempEncryptedDb(tempPrefix);
  });
  return out;
}

/// Pops [rootNavigator] if possible, then replaces the root widget and pumps
/// so Drift stream teardown timers run under the test binding's fake clock.
Future<void> resetWidgetBindingAfterDriftStreams(
  WidgetTester tester, {
  GlobalKey<NavigatorState>? rootNavigator,
}) async {
  final nav = rootNavigator?.currentState;
  if (nav != null && nav.canPop()) {
    nav.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Two zero-duration pumps: enough for a synchronous [Navigator.push] (as
/// used by `navigateFromNotificationTap`) to install and build the new route
/// under the test binding.
Future<void> pumpSteadyNavigationFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}
