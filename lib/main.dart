import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'core/constants/app_constants.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set lokasi timezone device. Untuk kesederhanaan awal kita pakai UTC
  // sebagai default aman; penentuan zona waktu device yang presisi bisa
  // ditambahkan dengan package `flutter_timezone` di iterasi berikutnya
  // tanpa mengubah cara NotificationService dipakai.
  tz.setLocalLocation(tz.getLocation('UTC'));

  runApp(const ProviderScope(child: _AppInitializer()));
}

/// Widget kecil untuk menginisialisasi NotificationService setelah
/// ProviderScope siap, karena service butuh akses ke provider container
/// untuk menangani action notifikasi (mark done / snooze).
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNotifications());
  }

  Future<void> _initNotifications() async {
    final service = ref.read(notificationServiceProvider);
    await service.init(
      onAction: (actionId, reminderId) async {
        if (reminderId == null) return;
        final repo = ref.read(reminderRepositoryProvider);
        final reminder = await repo.getReminderById(reminderId);
        if (reminder == null) return;

        if (actionId == NotificationActions.markDone) {
          await repo.markCompleted(reminderId, true);
        } else if (actionId == NotificationActions.snooze5) {
          await service.scheduleSnooze(reminder, const Duration(minutes: 5));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
