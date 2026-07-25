/// Kumpulan konstanta global aplikasi.
/// Dipisah dari kode fitur supaya mudah diubah tanpa menyentuh business logic.
class AppConstants {
  AppConstants._();

  static const String appName = 'Reminder & Diary';
  static const String dbFileName = 'reminder_diary.sqlite';

  // Secure storage keys
  static const String keyPinHash = 'diary_pin_hash_v1';
  static const String keyPinSalt = 'diary_pin_salt_v1';
  static const String keyEncryptionKey = 'diary_encryption_key_v1';

  // Preferences keys
  static const String prefDarkMode = 'pref_dark_mode';
  static const String prefTimeFormat24h = 'pref_time_format_24h';

  // Notification
  static const String notifChannelId = 'reminder_channel';
  static const String notifChannelName = 'Reminder';
  static const String notifChannelDesc = 'Notifikasi untuk pengingat kamu';
}

/// Pilihan kapan pengguna ingin diingatkan sebelum waktu reminder.
enum PreReminderOption {
  onTime(Duration.zero, 'Tepat waktu'),
  min5(Duration(minutes: 5), '5 menit sebelumnya'),
  min10(Duration(minutes: 10), '10 menit sebelumnya'),
  min15(Duration(minutes: 15), '15 menit sebelumnya'),
  min30(Duration(minutes: 30), '30 menit sebelumnya'),
  hour1(Duration(hours: 1), '1 jam sebelumnya'),
  day1(Duration(days: 1), '1 hari sebelumnya');

  const PreReminderOption(this.offset, this.label);
  final Duration offset;
  final String label;
}

enum RepeatType { none, daily, weekly, monthly }

enum ReminderPriority { low, medium, high }
