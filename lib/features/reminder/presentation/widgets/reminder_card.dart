import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reminder_entity.dart';

/// Kartu reminder — dibuat sederhana (satu warna aksen dengan variasi
/// intensitas untuk prioritas, bukan banyak warna berbeda) supaya
/// terasa "simpel", tapi tetap ada animasi halus di checkbox & saat
/// muncul di list.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDismiss,
  });

  final ReminderEntity reminder;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDismiss;

  double _priorityOpacity() {
    switch (reminder.priority) {
      case ReminderPriority.high:
        return 1.0;
      case ReminderPriority.medium:
        return 0.6;
      case ReminderPriority.low:
        return 0.35;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('EEE, d MMM • HH:mm').format(reminder.dateTime);
    final accent = AppColors.primary.withValues(alpha: _priorityOpacity());

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.priorityHigh.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
      ),
      onDismissed: (_) => onDismiss(),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: reminder.isCompleted
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        child: Text(reminder.title),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$timeLabel • ${reminder.category}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      if (reminder.isOverdue)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Terlambat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.priorityHigh,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _AnimatedCompleteCheckbox(
                  completed: reminder.isCompleted,
                  onTap: onToggleComplete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Checkbox bulat dengan animasi scale + fade halus saat berpindah
/// status selesai/belum, dipisah jadi widget sendiri supaya animasinya
/// terisolasi dan tidak ikut ter-rebuild oleh perubahan lain di kartu.
class _AnimatedCompleteCheckbox extends StatelessWidget {
  const _AnimatedCompleteCheckbox({required this.completed, required this.onTap});
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            completed ? Icons.check_circle : Icons.check_circle_outline,
            key: ValueKey(completed),
            color: completed
                ? AppColors.priorityLow
                : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
