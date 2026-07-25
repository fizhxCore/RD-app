import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';

/// Hasil enkripsi satu entry: ciphertext + IV (keduanya perlu disimpan
/// untuk bisa didekripsi kembali; IV boleh disimpan plaintext karena
/// bukan rahasia, hanya harus unik per entry).
class EncryptedPayload {
  const EncryptedPayload({required this.cipherText, required this.iv});
  final String cipherText;
  final String iv;
}

/// Mengenkripsi/mendekripsi isi catatan diary dengan AES-256-CBC.
///
/// Key AES diturunkan dari PIN pengguna (bukan disimpan terpisah di
/// plaintext), lalu key itu sendiri disimpan di secure storage
/// terenkripsi oleh OS Keystore/Keychain sehingga hanya bisa diakses
/// oleh app ini di device yang sama.
class DiaryEncryptionService {
  DiaryEncryptionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// Dipanggil sekali saat PIN pertama kali dibuat, untuk membuat
  /// & menyimpan key enkripsi yang diturunkan dari PIN tersebut.
  Future<void> generateKeyFromPin(String pin) async {
    final key = _deriveKey(pin);
    await _storage.write(key: AppConstants.keyEncryptionKey, value: key.base64);
  }

  Future<EncryptedPayload> encrypt(String plainText) async {
    final key = await _loadKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return EncryptedPayload(cipherText: encrypted.base64, iv: iv.base64);
  }

  Future<String> decrypt(String cipherTextBase64, String ivBase64) async {
    final key = await _loadKey();
    final iv = enc.IV.fromBase64(ivBase64);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    try {
      return encrypter.decrypt64(cipherTextBase64, iv: iv);
    } catch (_) {
      throw const EncryptionException('Gagal membuka catatan, PIN mungkin tidak sesuai');
    }
  }

  Future<enc.Key> _loadKey() async {
    final stored = await _storage.read(key: AppConstants.keyEncryptionKey);
    if (stored == null) {
      throw const PinNotSetException('Encryption key belum tersedia, atur PIN dulu');
    }
    return enc.Key.fromBase64(stored);
  }

  /// Menurunkan key 256-bit dari PIN memakai SHA-256.
  /// Ini bukan KDF dengan iterasi (bukan PBKDF2/Argon2) — cukup untuk
  /// scope aplikasi personal ini, tapi dicatat sebagai trade-off:
  /// untuk keamanan lebih tinggi, bisa diganti PBKDF2 dengan salt
  /// tersimpan terpisah tanpa mengubah struktur pemanggilan di layer atas.
  enc.Key _deriveKey(String pin) {
    final digest = sha256.convert(utf8.encode(pin));
    return enc.Key(Uint8ListFromDigest(digest));
  }
}

// Helper kecil supaya tidak perlu import dart:typed_data terpisah di banyak tempat.
List<int> Uint8ListFromDigest(Digest digest) => digest.bytes;
