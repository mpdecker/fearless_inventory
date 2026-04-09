import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_secure_storage.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Value type
// ─────────────────────────────────────────────────────────────────────────────

class SponsorCallConfig {
  /// Whether the scheduled reminder is active.
  final bool enabled;

  /// 'daily' or 'weekly'.
  final String frequency;

  /// Hour of day (0–23) to fire the reminder.
  final int hour;

  /// Minute of hour (0–59) to fire the reminder.
  final int minute;

  /// ISO weekday (1 = Monday … 7 = Sunday). Only used when [frequency] is
  /// 'weekly'.
  final int weekday;

  /// Sponsor's phone number, or null if not set.
  final String? phone;

  const SponsorCallConfig({
    required this.enabled,
    required this.frequency,
    required this.hour,
    required this.minute,
    required this.weekday,
    this.phone,
  });

  static const SponsorCallConfig defaults = SponsorCallConfig(
    enabled: false,
    frequency: 'daily',
    hour: 9,
    minute: 0,
    weekday: 1, // Monday
  );

  SponsorCallConfig copyWith({
    bool? enabled,
    String? frequency,
    int? hour,
    int? minute,
    int? weekday,
    String? phone,
    bool clearPhone = false,
  }) =>
      SponsorCallConfig(
        enabled: enabled ?? this.enabled,
        frequency: frequency ?? this.frequency,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        weekday: weekday ?? this.weekday,
        phone: clearPhone ? null : (phone ?? this.phone),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Persists sponsor-call reminder preferences in the OS keystore / keychain.
class SponsorCallPrefs {
  static const _kEnabled = 'sponsor_call_reminder_enabled';
  static const _kFrequency = 'sponsor_call_reminder_frequency';
  static const _kHour = 'sponsor_call_reminder_hour';
  static const _kMinute = 'sponsor_call_reminder_minute';
  static const _kWeekday = 'sponsor_call_reminder_weekday';
  static const _kPhone = 'sponsor_phone';

  final FlutterSecureStorage _storage;

  const SponsorCallPrefs([FlutterSecureStorage? storage])
      : _storage = storage ?? appSecureStorage;

  Future<SponsorCallConfig> load() async {
    final results = await Future.wait([
      _storage.read(key: _kEnabled),
      _storage.read(key: _kFrequency),
      _storage.read(key: _kHour),
      _storage.read(key: _kMinute),
      _storage.read(key: _kWeekday),
      _storage.read(key: _kPhone),
    ]);

    return SponsorCallConfig(
      enabled: results[0] == 'true',
      frequency: results[1] ?? 'daily',
      hour: int.tryParse(results[2] ?? '') ?? 9,
      minute: int.tryParse(results[3] ?? '') ?? 0,
      weekday: int.tryParse(results[4] ?? '') ?? 1,
      phone: results[5],
    );
  }

  Future<void> save(SponsorCallConfig config) async {
    await Future.wait([
      _storage.write(key: _kEnabled, value: config.enabled.toString()),
      _storage.write(key: _kFrequency, value: config.frequency),
      _storage.write(key: _kHour, value: config.hour.toString()),
      _storage.write(key: _kMinute, value: config.minute.toString()),
      _storage.write(key: _kWeekday, value: config.weekday.toString()),
    ]);
    if (config.phone != null) {
      await _storage.write(key: _kPhone, value: config.phone!);
    } else {
      await _storage.delete(key: _kPhone);
    }
  }
}
