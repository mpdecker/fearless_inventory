import 'package:flutter/material.dart';

/// Global key for [MaterialApp.navigatorKey] so notification taps can navigate
/// without a [BuildContext] from the widget that registered the listener.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
