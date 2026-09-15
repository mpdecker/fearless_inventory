import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fearless_inventory/core/services/cloud_backup_envelope.dart';

void main() {
  group('encodeBackupEnvelope / decodeBackupEnvelope', () {
    test('round-trips salt, iv, and ciphertext', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final iv = Uint8List.fromList(List.generate(12, (i) => i + 100));
      final ciphertext = Uint8List.fromList(List.generate(40, (i) => i + 200));

      final encoded = encodeBackupEnvelope(salt: salt, iv: iv, ciphertext: ciphertext);
      final decoded = decodeBackupEnvelope(encoded);

      expect(decoded.salt, equals(salt));
      expect(decoded.iv, equals(iv));
      expect(decoded.ciphertext, equals(ciphertext));
    });

    test('encoded bytes start with version byte 1', () {
      final encoded = encodeBackupEnvelope(
        salt: Uint8List(16),
        iv: Uint8List(12),
        ciphertext: Uint8List(4),
      );
      expect(encoded[0], 1);
    });

    test('decodeBackupEnvelope throws FormatException on an unsupported version byte', () {
      final bytes = Uint8List.fromList([99, ...List.filled(28, 0)]);
      expect(() => decodeBackupEnvelope(bytes), throwsFormatException);
    });

    test('decodeBackupEnvelope throws FormatException on input too short to contain a header', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(() => decodeBackupEnvelope(bytes), throwsFormatException);
    });

    test('handles an empty ciphertext', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));
      final iv = Uint8List.fromList(List.generate(12, (i) => i));
      final encoded = encodeBackupEnvelope(salt: salt, iv: iv, ciphertext: Uint8List(0));
      final decoded = decodeBackupEnvelope(encoded);
      expect(decoded.ciphertext, isEmpty);
    });
  });
}
