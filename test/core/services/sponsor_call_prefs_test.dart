import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/sponsor_call_prefs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// In-memory FlutterSecureStorage fake (re-use pattern from pin_service_test)
// ─────────────────────────────────────────────────────────────────────────────

class _FakeStorage extends Fake implements FlutterSecureStorage {
  final _data = <String, String>{};

  @override
  Future<String?> read({required String key, IOSOptions? iOptions,
      AndroidOptions? aOptions, LinuxOptions? lOptions,
      WebOptions? webOptions, MacOsOptions? mOptions,
      WindowsOptions? wOptions}) async => _data[key];

  @override
  Future<void> write({required String key, required String? value,
      IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions,
      WebOptions? webOptions, MacOsOptions? mOptions,
      WindowsOptions? wOptions}) async {
    if (value == null) _data.remove(key); else _data[key] = value;
  }

  @override
  Future<void> delete({required String key, IOSOptions? iOptions,
      AndroidOptions? aOptions, LinuxOptions? lOptions,
      WebOptions? webOptions, MacOsOptions? mOptions,
      WindowsOptions? wOptions}) async => _data.remove(key);
}

void main() {
  group('SponsorCallConfig.copyWith', () {
    const base = SponsorCallConfig(
      enabled:   true,
      frequency: 'daily',
      hour:      9,
      minute:    0,
      weekday:   1,
      phone:     '555-0100',
    );

    test('identity — returns object with same values', () {
      final copy = base.copyWith();
      expect(copy.enabled,   base.enabled);
      expect(copy.frequency, base.frequency);
      expect(copy.hour,      base.hour);
      expect(copy.minute,    base.minute);
      expect(copy.weekday,   base.weekday);
      expect(copy.phone,     base.phone);
    });

    test('can change individual fields without affecting others', () {
      final copy = base.copyWith(hour: 18, minute: 30);
      expect(copy.hour,      18);
      expect(copy.minute,    30);
      expect(copy.enabled,   base.enabled);
      expect(copy.frequency, base.frequency);
      expect(copy.phone,     base.phone);
    });

    test('copyWith(phone: newPhone) updates phone', () {
      final copy = base.copyWith(phone: '555-9999');
      expect(copy.phone, '555-9999');
    });

    test('copyWith(clearPhone: true) sets phone to null', () {
      final copy = base.copyWith(clearPhone: true);
      expect(copy.phone, isNull);
    });

    test('clearPhone takes precedence over explicit phone', () {
      final copy = base.copyWith(phone: '555-1234', clearPhone: true);
      expect(copy.phone, isNull);
    });

    test('defaults constant has expected values', () {
      expect(SponsorCallConfig.defaults.enabled,   isFalse);
      expect(SponsorCallConfig.defaults.frequency, 'daily');
      expect(SponsorCallConfig.defaults.hour,      9);
      expect(SponsorCallConfig.defaults.minute,    0);
      expect(SponsorCallConfig.defaults.weekday,   1); // Monday
      expect(SponsorCallConfig.defaults.phone,     isNull);
    });
  });

  group('SponsorCallPrefs — load/save round-trips', () {
    late _FakeStorage storage;
    late SponsorCallPrefs prefs;

    setUp(() {
      storage = _FakeStorage();
      prefs = SponsorCallPrefs(storage);
    });

    test('load returns defaults when storage is empty', () async {
      final config = await prefs.load();
      expect(config.enabled,   isFalse);
      expect(config.frequency, 'daily');
      expect(config.hour,      9);
      expect(config.minute,    0);
      expect(config.weekday,   1);
      expect(config.phone,     isNull);
    });

    test('save then load round-trips all fields', () async {
      const toSave = SponsorCallConfig(
        enabled:   true,
        frequency: 'weekly',
        hour:      20,
        minute:    15,
        weekday:   5, // Friday
        phone:     '555-0042',
      );
      await prefs.save(toSave);
      final loaded = await prefs.load();

      expect(loaded.enabled,   isTrue);
      expect(loaded.frequency, 'weekly');
      expect(loaded.hour,      20);
      expect(loaded.minute,    15);
      expect(loaded.weekday,   5);
      expect(loaded.phone,     '555-0042');
    });

    test('save with null phone deletes the phone key', () async {
      // First save with a phone to put something in storage.
      await prefs.save(const SponsorCallConfig(
        enabled: true, frequency: 'daily', hour: 9, minute: 0, weekday: 1,
        phone: '555-1111',
      ));

      // Then save without a phone.
      await prefs.save(const SponsorCallConfig(
        enabled: true, frequency: 'daily', hour: 9, minute: 0, weekday: 1,
      ));

      final loaded = await prefs.load();
      expect(loaded.phone, isNull);
    });

    test('enabled=false round-trips correctly', () async {
      await prefs.save(const SponsorCallConfig(
        enabled: false, frequency: 'daily', hour: 9, minute: 0, weekday: 1,
      ));
      final loaded = await prefs.load();
      expect(loaded.enabled, isFalse);
    });

    test('overwriting a saved config replaces previous values', () async {
      await prefs.save(const SponsorCallConfig(
        enabled: true, frequency: 'daily', hour: 8, minute: 0, weekday: 1,
      ));
      await prefs.save(const SponsorCallConfig(
        enabled: false, frequency: 'weekly', hour: 18, minute: 30, weekday: 3,
      ));
      final loaded = await prefs.load();
      expect(loaded.enabled,   isFalse);
      expect(loaded.frequency, 'weekly');
      expect(loaded.hour,      18);
      expect(loaded.minute,    30);
      expect(loaded.weekday,   3);
    });
  });
}
