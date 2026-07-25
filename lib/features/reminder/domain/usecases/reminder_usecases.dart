import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

class GetAllReminders {
  const GetAllReminders(this._repository);
  final ReminderRepository _repository;
  Future<List<ReminderEntity>> call() => _repository.getAllReminders();
}

/// Menambah reminder baru SEKALIGUS menjadwalkan notifikasinya.
/// Digabung dalam satu use case karena keduanya harus selalu konsisten:
/// tidak boleh ada reminder tanpa notifikasi terjadwal (kecuali completed).
class AddReminder {
  const AddReminder(this._repository, this._notificationService);
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  Future<int> call(ReminderEntity reminder) async {
    final id = await _repository.addReminder(reminder);
    final notifId = await _notificationService.scheduleReminder(
      reminder.copyWith(id: id),
    );
    await _repository.setActiveNotificationId(id, notifId);
    return id;
  }
}

/// Edit reminder = batalkan notifikasi lama, simpan perubahan,
/// lalu jadwalkan ulang notifikasi baru berdasar data terbaru.
class EditReminder {
  const EditReminder(this._repository, this._notificationService);
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  Future<void> call(ReminderEntity reminder) async {
    if (reminder.activeNotificationId != null) {
      await _notificationService.cancelNotification(reminder.activeNotificationId!);
    }
    await _repository.updateReminder(reminder);
    if (!reminder.isCompleted) {
      final notifId = await _notificationService.scheduleReminder(reminder);
      await _repository.setActiveNotificationId(reminder.id!, notifId);
    } else {
      await _repository.setActiveNotificationId(reminder.id!, null);
    }
  }
}

class DeleteReminder {
  const DeleteReminder(this._repository, this._notificationService);
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  Future<void> call(ReminderEntity reminder) async {
    if (reminder.activeNotificationId != null) {
      await _notificationService.cancelNotification(reminder.activeNotificationId!);
    }
    await _repository.deleteReminder(reminder.id!);
  }
}

/// Menandai selesai. Jika reminder TIDAK berulang, notifikasi berikutnya
/// dibatalkan. Jika berulang, notifikasi berikutnya tetap berjalan sesuai
/// interval (menandai selesai hanya menutup instance saat ini).
class MarkReminderCompleted {
  const MarkReminderCompleted(this._repository, this._notificationService);
  final ReminderRepository _repository;
  final NotificationService _notificationService;

  Future<void> call(ReminderEntity reminder, bool completed) async {
    await _repository.markCompleted(reminder.id!, completed);
    if (completed && reminder.repeatType == RepeatType.none) {
      if (reminder.activeNotificationId != null) {
        await _notificationService.cancelNotification(reminder.activeNotificationId!);
        await _repository.setActiveNotificationId(reminder.id!, null);
      }
    }
  }
}

/// Snooze 5 menit: menjadwalkan notifikasi baru 5 menit dari sekarang
/// TANPA mengubah jadwal utama reminder (sesuai requirement awal).
class SnoozeReminder {
  const SnoozeReminder(this._notificationService);
  final NotificationService _notificationService;

  Future<int> call(ReminderEntity reminder) {
    return _notificationService.scheduleSnooze(reminder, const Duration(minutes: 5));
  }
}
