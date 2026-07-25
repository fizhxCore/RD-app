import '../../../../core/constants/app_constants.dart';

class ReminderEntity {
  const ReminderEntity({
    this.id,
    required this.title,
    this.note,
    required this.dateTime,
    this.priority = ReminderPriority.medium,
    this.category = 'Umum',
    this.colorValue = 0xFF6C63FF,
    this.repeatType = RepeatType.none,
    this.preReminder = PreReminderOption.onTime,
    this.isCompleted = false,
    this.activeNotificationId,
  });

  final int? id;
  final String title;
  final String? note;
  final DateTime dateTime;
  final ReminderPriority priority;
  final String category;
  final int colorValue;
  final RepeatType repeatType;
  final PreReminderOption preReminder;
  final bool isCompleted;
  final int? activeNotificationId;

  /// Waktu aktual notifikasi harus muncul (dateTime dikurangi offset pre-reminder).
  DateTime get notifyAt => dateTime.subtract(preReminder.offset);

  bool get isOverdue => !isCompleted && dateTime.isBefore(DateTime.now());

  ReminderEntity copyWith({
    int? id,
    String? title,
    String? note,
    DateTime? dateTime,
    ReminderPriority? priority,
    String? category,
    int? colorValue,
    RepeatType? repeatType,
    PreReminderOption? preReminder,
    bool? isCompleted,
    int? activeNotificationId,
  }) {
    return ReminderEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      repeatType: repeatType ?? this.repeatType,
      preReminder: preReminder ?? this.preReminder,
      isCompleted: isCompleted ?? this.isCompleted,
      activeNotificationId: activeNotificationId ?? this.activeNotificationId,
    );
  }
}
