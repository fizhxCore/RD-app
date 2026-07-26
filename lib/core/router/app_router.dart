import 'package:go_router/go_router.dart';

import '../../features/diary/domain/entities/diary_entry.dart';
import '../../features/diary/presentation/pages/diary_editor_page.dart';
import '../../features/diary/presentation/pages/pin_setup_page.dart';
import '../../features/reminder/domain/entities/reminder_entity.dart';
import '../../features/reminder/presentation/pages/add_edit_reminder_page.dart';
import '../../features/reminder/presentation/pages/reminder_detail_page.dart';
import '../widgets/root_shell.dart';
import '../widgets/splash_page.dart';
import 'smooth_page_transition.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => buildSmoothPage(
        state: state,
        child: const RootShell(),
      ),
    ),
    GoRoute(
      path: '/reminder/add',
      pageBuilder: (context, state) => buildSmoothPage(
        state: state,
        child: const AddEditReminderPage(),
      ),
    ),
    GoRoute(
      path: '/reminder/edit/:id',
      pageBuilder: (context, state) => buildSmoothPage(
        state: state,
        child: AddEditReminderPage(existing: state.extra as ReminderEntity?),
      ),
    ),
    GoRoute(
      path: '/reminder/detail/:id',
      pageBuilder: (context, state) => buildSmoothPage(
        state: state,
        child: ReminderDetailPage(
          reminderId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ),
    GoRoute(
      path: '/diary/editor',
      pageBuilder: (context, state) => buildSmoothPage(
        state: state,
        child: DiaryEditorPage(existing: state.extra as DiaryEntry?),
      ),
    ),
    GoRoute(
      path: '/diary/pin-setup',
      pageBuilder: (context, state) => buildSmoothPage(
        state: state,
        child: const PinSetupPage(),
      ),
    ),
  ],
);
