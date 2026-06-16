import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/navigation/adaptive_page_route.dart';

void main() {
  test('adaptivePageRoute uses CupertinoPageRoute on iOS', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final route = adaptivePageRoute<void>((_) => const SizedBox());
    expect(route, isA<CupertinoPageRoute<void>>());
  });

  test('adaptivePageRoute uses MaterialPageRoute on Android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final route = adaptivePageRoute<void>((_) => const SizedBox());
    expect(route, isA<MaterialPageRoute<void>>());
  });
}
