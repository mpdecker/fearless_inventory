import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialScrollBehavior uses bounce physics on iOS',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      late ScrollPhysics physics;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              physics =
                  const MaterialScrollBehavior().getScrollPhysics(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(physics, isA<BouncingScrollPhysics>());
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('MaterialScrollBehavior uses clamping physics on Android',
      (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      late ScrollPhysics physics;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              physics =
                  const MaterialScrollBehavior().getScrollPhysics(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(physics, isA<ClampingScrollPhysics>());
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
