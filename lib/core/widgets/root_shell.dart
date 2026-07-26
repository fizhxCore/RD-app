import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/diary/presentation/pages/diary_list_page.dart';
import '../../features/diary/presentation/pages/pin_lock_page.dart';
import '../../features/diary/presentation/pages/pin_setup_page.dart';
import '../../features/diary/presentation/providers/diary_providers.dart';
import '../../features/reminder/presentation/pages/home_page.dart';
import 'settings_page.dart';

/// Shell utama dengan 2 tab besar (Reminder & Diary) + Settings.
/// Tab Diary selalu dicek status kunci & PIN setiap kali dibuka —
/// ini yang mengimplementasikan auto-lock by design.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-lock: begitu app masuk background, diary dikunci lagi.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(diaryLockProvider.notifier).lock();
    }
  }

  Widget _diaryTab() {
    return FutureBuilder<bool>(
      future: ref.read(isPinSetUseCaseProvider).call(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!) {
          return const PinSetupPage();
        }
        final locked = ref.watch(diaryLockProvider);
        return locked ? const PinLockPage() : const DiaryListPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), _diaryTab(), const SettingsPage()];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Reminder'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Diary'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
