import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onComplete,
    super.key,
  });

  final FarmTask task;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: task.isOverdue
            ? Border.all(color: AppColors.error.withAlpha(77))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isCompleted ? null : onComplete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.success : Colors.transparent,
                border: isCompleted
                    ? null
                    : Border.all(color: AppColors.textTertiary, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(_typeIcon(task.type), size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${task.dueDate.month}/${task.dueDate.day}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: task.isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                    ),
                    if (task.dueTime != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        task.dueTime!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                    ],
                    if (task.recurrence != Recurrence.none) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.repeat,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (task.isOverdue)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: const Text(
                'Overdue',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _typeIcon(TaskType type) => switch (type) {
        TaskType.feeding => Icons.restaurant,
        TaskType.cleaning => Icons.cleaning_services,
        TaskType.vaccination => Icons.vaccines,
        TaskType.medicine => Icons.medication,
        TaskType.examination => Icons.search,
        TaskType.shedCheck => Icons.house,
        TaskType.eggCollection => Icons.egg,
        TaskType.waterCheck => Icons.water_drop,
        TaskType.biosecurity => Icons.security,
        TaskType.other => Icons.task_alt,
      };
}
