// Replace this file by running:
//   dart pub global activate flutterfire_cli && flutterfire configure
//
// Values below are syntactically valid placeholders so the project compiles.
// Authentication will not work until you configure a real Firebase project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0fi5vmBRVE_hgBF7KqFoUZJDLxtExjfk',
    appId: '1:510334238921:web:dd91d38952066a91be0d18',
    messagingSenderId: '510334238921',
    projectId: 'fearless-inventory',
    authDomain: 'fearless-inventory.firebaseapp.com',
    storageBucket: 'fearless-inventory.firebasestorage.app',
    measurementId: 'G-H6J26GVZYS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxNIE3E-i6nvk1tPU7vSpMbtRfTVcL6_s',
    appId: '1:510334238921:android:2fc2d88d1cac49b7be0d18',
    messagingSenderId: '510334238921',
    projectId: 'fearless-inventory',
    storageBucket: 'fearless-inventory.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdKWByxit2RtP27U6wuO1xETmOGoVk2kw',
    appId: '1:510334238921:ios:a85311d2bef79848be0d18',
    messagingSenderId: '510334238921',
    projectId: 'fearless-inventory',
    storageBucket: 'fearless-inventory.firebasestorage.app',
    iosBundleId: 'com.happydestiny.happydestiny',
  );

}