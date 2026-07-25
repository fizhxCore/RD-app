import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/reminder_providers.dart';

class ReminderDetailPage extends ConsumerWidget {
  const ReminderDetailPage({super.key, required this.reminderId});
  final int reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderListProvider).valueOrNull ?? [];
    final reminder = reminders.where((r) => r.id == reminderId).firstOrNull;

    if (reminder == null) {
      return const Scaffold(body: Center(child: Text('Reminder tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/reminder/edit/${reminder.id}', extra: reminder),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(reminderListProvider.notifier).remove(reminder);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(reminder.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(DateFormat('EEEE, d MMMM yyyy • HH:mm').format(reminder.dateTime)),
          const SizedBox(height: 8),
          Text('Kategori: ${reminder.category}'),
          Text('Prioritas: ${reminder.priority.name}'),
          Text('Ulangi: ${reminder.repeatType.name}'),
          Text('Ingatkan: ${reminder.preReminder.label}'),
          if (reminder.note != null) ...[
            const SizedBox(height: 16),
            Text(reminder.note!),
          ],
        ],
      ),
    );
  }
}
