import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/usecases/reminder_usecases.dart';

final addReminderUseCaseProvider = Provider((ref) {
  return AddReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

final editReminderUseCaseProvider = Provider((ref) {
  return EditReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

final deleteReminderUseCaseProvider = Provider((ref) {
  return DeleteReminder(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

final markCompletedUseCaseProvider = Provider((ref) {
  return MarkReminderCompleted(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

final snoozeReminderUseCaseProvider = Provider((ref) {
  return SnoozeReminder(ref.watch(notificationServiceProvider));
});

/// Menyimpan & mengekspos daftar reminder terbaru. AsyncNotifier dipakai
/// (bukan FutureProvider biasa) supaya mudah di-refresh manual setelah
/// operasi tambah/edit/hapus tanpa perlu invalidate provider lain.
class ReminderListNotifier extends AsyncNotifier<List<ReminderEntity>> {
  @override
  Future<List<ReminderEntity>> build() {
    return ref.watch(reminderRepositoryProvider).getAllReminders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(reminderRepositoryProvider).getAllReminders(),
    );
  }

  Future<void> add(ReminderEntity reminder) async {
    await ref.read(addReminderUseCaseProvider).call(reminder);
    await refresh();
  }

  Future<void> edit(ReminderEntity reminder) async {
    await ref.read(editReminderUseCaseProvider).call(reminder);
    await refresh();
  }

  Future<void> remove(ReminderEntity reminder) async {
    await ref.read(deleteReminderUseCaseProvider).call(reminder);
    await refresh();
  }

  Future<void> toggleCompleted(ReminderEntity reminder) async {
    await ref
        .read(markCompletedUseCaseProvider)
        .call(reminder, !reminder.isCompleted);
    await refresh();
  }
}

final reminderListProvider =
    AsyncNotifierProvider<ReminderListNotifier, List<ReminderEntity>>(
  ReminderListNotifier.new,
);

/// Grouping untuk Home Screen: Hari Ini, Akan Datang, Terlambat, Selesai.
class ReminderGroups {
  const ReminderGroups({
    required this.today,
    required this.upcoming,
    required this.overdue,
    required this.completed,
  });

  final List<ReminderEntity> today;
  final List<ReminderEntity> upcoming;
  final List<ReminderEntity> overdue;
  final List<ReminderEntity> completed;
}

final reminderGroupsProvider = Provider<ReminderGroups>((ref) {
  final reminders = ref.watch(reminderListProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = <ReminderEntity>[];
  final upcoming = <ReminderEntity>[];
  final overdue = <ReminderEntity>[];
  final completed = <ReminderEntity>[];

  for (final r in reminders) {
    if (r.isCompleted) {
      completed.add(r);
    } else if (r.dateTime.isBefore(now)) {
      overdue.add(r);
    } else if (_isSameDay(r.dateTime, now)) {
      today.add(r);
    } else {
      upcoming.add(r);
    }
  }
  return ReminderGroups(
    today: today,
    upcoming: upcoming,
    overdue: overdue,
    completed: completed,
  );
});

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
