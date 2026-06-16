import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

/// Uses [CupertinoPageRoute] on iOS (edge swipe to go back) and
/// [MaterialPageRoute] elsewhere.
PageRoute<T> adaptivePageRoute<T>(
  WidgetBuilder builder, {
  bool fullscreenDialog = false,
}) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    return CupertinoPageRoute<T>(
      builder: builder,
      fullscreenDialog: fullscreenDialog,
    );
  }
  return MaterialPageRoute<T>(
    builder: builder,
    fullscreenDialog: fullscreenDialog,
  );
}
