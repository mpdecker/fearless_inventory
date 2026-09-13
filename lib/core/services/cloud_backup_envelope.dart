import 'dart:typed_data';

/// Binary format for the object uploaded to Firebase Storage at
/// `users/{uid}/db_backup.enc`: the exact same salt/iv/ciphertext the local
/// IndexedDB envelope already stores (see `web_db_envelope.dart`), just
/// concatenated with a leading version byte so the format can evolve later.
///
/// ```
/// [1 byte version = 0x01][16 bytes salt][12 bytes IV][ciphertext...]
/// ```
const int _currentVersion = 1;
const int _saltLength = 16;
const int _ivLength = 12;
const int _headerLength = 1 + _saltLength + _ivLength;

class DecodedBackupEnvelope {
  final Uint8List salt;
  final Uint8List iv;
  final Uint8List ciphertext;
  const DecodedBackupEnvelope({
    required this.salt,
    required this.iv,
    required this.ciphertext,
  });
}

Uint8List encodeBackupEnvelope({
  required Uint8List salt,
  required Uint8List iv,
  required Uint8List ciphertext,
}) {
  final out = BytesBuilder();
  out.addByte(_currentVersion);
  out.add(salt);
  out.add(iv);
  out.add(ciphertext);
  return out.toBytes();
}

DecodedBackupEnvelope decodeBackupEnvelope(Uint8List bytes) {
  if (bytes.length < _headerLength) {
    throw FormatException(
      'Backup envelope too short: expected at least $_headerLength bytes, got ${bytes.length}',
    );
  }
  if (bytes[0] != _currentVersion) {
    throw FormatException('Unsupported backup envelope version: ${bytes[0]}');
  }
  final salt = bytes.sublist(1, 1 + _saltLength);
  final iv = bytes.sublist(1 + _saltLength, _headerLength);
  final ciphertext = bytes.sublist(_headerLength);
  return DecodedBackupEnvelope(salt: salt, iv: iv, ciphertext: ciphertext);
}
