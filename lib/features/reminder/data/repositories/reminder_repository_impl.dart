import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database/app_database.dart' as db;
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasource/reminder_local_datasource.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._local);
  final ReminderLocalDataSource _local;

  @override
  Future<List<ReminderEntity>> getAllReminders() async {
    final rows = await _local.getAll();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<ReminderEntity?> getReminderById(int id) async {
    final row = await _local.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<int> addReminder(ReminderEntity reminder) {
    return _local.insert(db.RemindersCompanion.insert(
      title: reminder.title,
      note: db.Value(reminder.note),
      dueAt: reminder.dateTime,
      priority: db.Value(reminder.priority.name),
      category: db.Value(reminder.category),
      colorValue: db.Value(reminder.colorValue),
      repeatType: db.Value(reminder.repeatType.name),
      preReminder: db.Value(reminder.preReminder.name),
    ));
  }

  @override
  Future<void> updateReminder(ReminderEntity reminder) {
    return _local.update(
      reminder.id!,
      db.RemindersCompanion(
        title: db.Value(reminder.title),
        note: db.Value(reminder.note),
        dueAt: db.Value(reminder.dateTime),
        priority: db.Value(reminder.priority.name),
        category: db.Value(reminder.category),
        colorValue: db.Value(reminder.colorValue),
        repeatType: db.Value(reminder.repeatType.name),
        preReminder: db.Value(reminder.preReminder.name),
        isCompleted: db.Value(reminder.isCompleted),
        updatedAt: db.Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteReminder(int id) => _local.deleteById(id);

  @override
  Future<void> markCompleted(int id, bool completed) {
    return _local.update(
      id,
      db.RemindersCompanion(isCompleted: db.Value(completed)),
    );
  }

  @override
  Future<void> setActiveNotificationId(int reminderId, int? notificationId) {
    return _local.update(
      reminderId,
      db.RemindersCompanion(activeNotificationId: db.Value(notificationId)),
    );
  }

  ReminderEntity _toEntity(db.Reminder row) {
    return ReminderEntity(
      id: row.id,
      title: row.title,
      note: row.note,
      dateTime: row.dueAt,
      priority: ReminderPriority.values.byName(row.priority),
      category: row.category,
      colorValue: row.colorValue,
      repeatType: RepeatType.values.byName(row.repeatType),
      preReminder: PreReminderOption.values.byName(row.preReminder),
      isCompleted: row.isCompleted,
      activeNotificationId: row.activeNotificationId,
    );
  }
}
