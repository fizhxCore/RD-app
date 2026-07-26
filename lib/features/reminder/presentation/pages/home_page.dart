import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderListProvider);
    final groups = ref.watch(reminderGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder')),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(reminderListProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              if (groups.overdue.isNotEmpty)
                _Section(title: 'Terlambat', reminders: groups.overdue, ref: ref),
              _Section(title: 'Hari Ini', reminders: groups.today, ref: ref),
              _Section(title: 'Akan Datang', reminders: groups.upcoming, ref: ref),
              _Section(title: 'Selesai', reminders: groups.completed, ref: ref),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reminder/add'),
        icon: const Icon(Icons.add),
        label: const Text('Reminder'),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.reminders, required this.ref});

  final String title;
  final List<ReminderEntity> reminders;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 10, left: 4),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        ...reminders.asMap().entries.map((entry) {
          final index = entry.key;
          final reminder = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReminderCard(
              reminder: reminder,
              onTap: () => context.push('/reminder/detail/${reminder.id}'),
              onToggleComplete: () =>
                  ref.read(reminderListProvider.notifier).toggleCompleted(reminder),
              onDismiss: () => ref.read(reminderListProvider.notifier).remove(reminder),
            )
                .animate()
                .fadeIn(delay: (index * 45).ms, duration: 320.ms, curve: Curves.easeOut)
                .slideY(begin: 0.06, end: 0, duration: 320.ms, curve: Curves.easeOutCubic),
          );
        }),
      ],
    );
  }
}
