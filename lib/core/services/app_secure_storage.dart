import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Single [FlutterSecureStorage] configuration for all app secrets (DB key,
/// onboarding, tab visits, sobriety date).
///
/// iOS: [KeychainAccessibility.first_unlock] maps to
/// `kSecAttrAccessibleAfterFirstUnlock`, so values remain available for
/// background work and notifications after the first device unlock.
final FlutterSecureStorage appSecureStorage = FlutterSecureStorage(
  aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  iOptions: const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
