import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/diary_entry.dart';
import '../providers/diary_providers.dart';

class DiaryListPage extends ConsumerWidget {
  const DiaryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Kunci sekarang',
            onPressed: () => ref.read(diaryLockProvider.notifier).lock(),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('Belum ada catatan. Mulai tulis sesuatu.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final entry = entries[i];
              return _DiaryTile(entry: entry)
                  .animate()
                  .fadeIn(delay: (i * 40).ms)
                  .slideY(begin: 0.06, end: 0);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.diaryAccent,
        onPressed: () => context.push('/diary/editor'),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Catatan'),
      ),
    );
  }
}

class _DiaryTile extends StatelessWidget {
  const _DiaryTile({required this.entry});
  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final preview = entry.content.length > 90
        ? '${entry.content.substring(0, 90)}…'
        : entry.content;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/diary/editor', extra: entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(entry.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  if (entry.mood != null)
                    Chip(
                      label: Text(entry.mood!),
                      backgroundColor: AppColors.diaryAccent.withValues(alpha: 0.15),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('d MMM yyyy • HH:mm').format(entry.updatedAt)} • ${entry.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
