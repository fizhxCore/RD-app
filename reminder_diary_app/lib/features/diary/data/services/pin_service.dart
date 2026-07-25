import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';

/// Mengelola PIN diary: hashing, penyimpanan, dan verifikasi.
///
/// Kenapa hash bukan plaintext:
/// PIN tidak pernah disimpan apa adanya. Kita simpan salt acak + hash
/// SHA-256(pin + salt), jadi walau storage bocor, PIN asli tidak bisa
/// langsung dibaca.
///
/// Trade-off: karena encryption key data diary diturunkan dari PIN,
/// jika pengguna reset PIN tanpa tahu PIN lama, seluruh data diary lama
/// tidak bisa didekripsi lagi. Ini disengaja demi keamanan (bukan bug),
/// dan harus diberi tahu jelas ke pengguna di halaman setup PIN.
class PinService {
  PinService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: AppConstants.keyPinHash);
    return hash != null;
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: AppConstants.keyPinSalt, value: salt);
    await _storage.write(key: AppConstants.keyPinHash, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: AppConstants.keyPinSalt);
    final storedHash = await _storage.read(key: AppConstants.keyPinHash);
    if (salt == null || storedHash == null) {
      throw const PinNotSetException();
    }
    final inputHash = _hashPin(pin, salt);
    return inputHash == storedHash;
  }

  /// Menghapus PIN & (di layer atas) trigger penghapusan semua data diary,
  /// karena encryption key ikut hilang bersama PIN lama.
  Future<void> clearPin() async {
    await _storage.delete(key: AppConstants.keyPinHash);
    await _storage.delete(key: AppConstants.keyPinSalt);
    await _storage.delete(key: AppConstants.keyEncryptionKey);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt');
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(values);
  }
}
