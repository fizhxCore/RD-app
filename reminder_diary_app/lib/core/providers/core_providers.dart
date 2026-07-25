import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/diary/data/datasource/diary_local_datasource.dart';
import '../../features/diary/data/repositories/diary_repository_impl.dart';
import '../../features/diary/data/services/diary_encryption_service.dart';
import '../../features/diary/data/services/pin_service.dart';
import '../../features/diary/domain/repositories/diary_repository.dart';
import '../../features/reminder/data/datasource/reminder_local_datasource.dart';
import '../../features/reminder/data/repositories/reminder_repository_impl.dart';
import '../../features/reminder/domain/repositories/reminder_repository.dart';
import '../services/database/app_database.dart';
import '../services/notification_service.dart';

/// Database Drift - satu instance untuk seluruh app (reminder & diary
/// berbagi file database yang sama, tapi tabel terpisah).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// --- Reminder DI chain ---
final reminderLocalDataSourceProvider = Provider<ReminderLocalDataSource>((ref) {
  return ReminderLocalDataSource(ref.watch(appDatabaseProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(ref.watch(reminderLocalDataSourceProvider));
});

// --- Diary DI chain ---
final diaryLocalDataSourceProvider = Provider<DiaryLocalDataSource>((ref) {
  return DiaryLocalDataSource(ref.watch(appDatabaseProvider));
});

final pinServiceProvider = Provider<PinService>((ref) => PinService());

final diaryEncryptionServiceProvider = Provider<DiaryEncryptionService>((ref) {
  return DiaryEncryptionService();
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepositoryImpl(
    localDataSource: ref.watch(diaryLocalDataSourceProvider),
    encryptionService: ref.watch(diaryEncryptionServiceProvider),
    pinService: ref.watch(pinServiceProvider),
  );
});
