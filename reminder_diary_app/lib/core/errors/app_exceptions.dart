/// Exception dasar aplikasi. Semua exception custom harus extend ini
/// supaya bisa ditangkap secara seragam di layer presentation.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Terjadi kesalahan pada database']);
}

class NotificationException extends AppException {
  const NotificationException([super.message = 'Gagal menjadwalkan notifikasi']);
}

class InvalidPinException extends AppException {
  const InvalidPinException([super.message = 'PIN salah']);
}

class PinNotSetException extends AppException {
  const PinNotSetException([super.message = 'PIN belum diatur']);
}

class EncryptionException extends AppException {
  const EncryptionException([super.message = 'Gagal memproses enkripsi data']);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
