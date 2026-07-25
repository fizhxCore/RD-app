import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<List<ReminderEntity>> getAllReminders();
  Future<ReminderEntity?> getReminderById(int id);
  Future<int> addReminder(ReminderEntity reminder);
  Future<void> updateReminder(ReminderEntity reminder);
  Future<void> deleteReminder(int id);
  Future<void> markCompleted(int id, bool completed);
  Future<void> setActiveNotificationId(int reminderId, int? notificationId);
}
