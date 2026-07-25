import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminder/domain/entities/reminder_entity.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import 'logger_service.dart';

/// Action ID untuk tombol pada notifikasi.
class NotificationActions {
  static const String markDone = 'action_mark_done';
  static const String snooze5 = 'action_snooze_5';
}

/// Membungkus flutter_local_notifications + timezone.
///
/// Kenapa timezone, bukan DateTime.now():
/// DateTime.now() tergantung jam device saat KODE DIJALANKAN, sedangkan
/// notifikasi terjadwal butuh referensi zona waktu yang tetap valid
/// walau pengguna berpindah zona waktu setelah notifikasi dijadwalkan.
/// Package `timezone` menyimpan target waktu sebagai TZDateTime yang
/// terikat ke lokasi tertentu, sehingga tetap akurat.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> init({
    required void Function(String actionId, int? reminderId) onAction,
  }) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Catatan: penentuan lokasi timezone device sesungguhnya dilakukan
    // lewat package `flutter_timezone` di main.dart sebelum init ini
    // dipanggil, lalu di-set via tz.setLocalLocation(...).

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final reminderId = int.tryParse(response.payload ?? '');
        onAction(response.actionId ?? '', reminderId);
      },
    );

    const channel = AndroidNotificationChannel(
      AppConstants.notifChannelId,
      AppConstants.notifChannelName,
      description: AppConstants.notifChannelDesc,
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Menjadwalkan notifikasi untuk sebuah reminder, termasuk offset
  /// pre-reminder. Mengembalikan ID notifikasi yang dipakai, supaya
  /// bisa dibatalkan/diganti nanti.
  Future<int> scheduleReminder(ReminderEntity reminder) async {
    final notifyAt = reminder.notifyAt;
    final notifId = _notificationIdFor(reminder.id!);

    final isOnTime = reminder.preReminder == PreReminderOption.onTime;
    final body = isOnTime
        ? 'Sekarang waktunya ${reminder.title}.'
        : '${reminder.title} dimulai dalam ${reminder.preReminder.label.replaceAll(' sebelumnya', '')}.';

    try {
      await _plugin.zonedSchedule(
        notifId,
        '🔔 Waktunya Reminder',
        body,
        tz.TZDateTime.from(notifyAt, tz.local),
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.id.toString(),
        matchDateTimeComponents: null, // reschedule manual, bukan otomatis
      );
      return notifId;
    } catch (e) {
      LoggerService.error('Gagal menjadwalkan notifikasi', e);
      throw const NotificationException();
    }
  }

  /// Dipakai saat reminder berulang selesai di satu siklus — jadwalkan
  /// instance berikutnya secara manual sesuai repeatType.
  DateTime nextOccurrence(DateTime current, RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return current.add(const Duration(days: 1));
      case RepeatType.weekly:
        return current.add(const Duration(days: 7));
      case RepeatType.monthly:
        return DateTime(current.year, current.month + 1, current.day,
            current.hour, current.minute);
      case RepeatType.none:
        return current;
    }
  }

  Future<int> scheduleSnooze(ReminderEntity reminder, Duration delay) async {
    final snoozeId = _notificationIdFor(reminder.id!) + 900000; // namespace terpisah
    final target = DateTime.now().add(delay);
    await _plugin.zonedSchedule(
      snoozeId,
      '🔔 Waktunya Reminder',
      'Sekarang waktunya ${reminder.title}.',
      tz.TZDateTime.from(target, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: reminder.id.toString(),
    );
    return snoozeId;
  }

  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  Future<void> cancelAllForReminder(int reminderId) async {
    await _plugin.cancel(_notificationIdFor(reminderId));
    await _plugin.cancel(_notificationIdFor(reminderId) + 900000);
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notifChannelId,
        AppConstants.notifChannelName,
        channelDescription: AppConstants.notifChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(
            NotificationActions.markDone,
            '✅ Tandai Selesai',
          ),
          AndroidNotificationAction(
            NotificationActions.snooze5,
            '⏰ Snooze 5 Menit',
          ),
        ],
      ),
    );
  }

  int _notificationIdFor(int reminderId) => reminderId;
}
