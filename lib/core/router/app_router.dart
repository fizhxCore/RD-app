import 'package:go_router/go_router.dart';

import '../../features/diary/domain/entities/diary_entry.dart';
import '../../features/diary/presentation/pages/diary_editor_page.dart';
import '../../features/diary/presentation/pages/pin_setup_page.dart';
import '../../features/reminder/domain/entities/reminder_entity.dart';
import '../../features/reminder/presentation/pages/add_edit_reminder_page.dart';
import '../../features/reminder/presentation/pages/reminder_detail_page.dart';
import '../widgets/root_shell.dart';
import '../widgets/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/home', builder: (context, state) => const RootShell()),
    GoRoute(
      path: '/reminder/add',
      builder: (context, state) => const AddEditReminderPage(),
    ),
    GoRoute(
      path: '/reminder/edit/:id',
      builder: (context, state) => AddEditReminderPage(
        existing: state.extra as ReminderEntity?,
      ),
    ),
    GoRoute(
      path: '/reminder/detail/:id',
      builder: (context, state) => ReminderDetailPage(
        reminderId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/diary/editor',
      builder: (context, state) => DiaryEditorPage(
        existing: state.extra as DiaryEntry?,
      ),
    ),
    GoRoute(
      path: '/diary/pin-setup',
      builder: (context, state) => const PinSetupPage(),
    ),
  ],
);
