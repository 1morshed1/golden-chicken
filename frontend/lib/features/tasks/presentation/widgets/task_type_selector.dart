import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';

class TaskTypeSelector extends StatelessWidget {
  const TaskTypeSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final TaskType selected;
  final ValueChanged<TaskType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: TaskType.values.map((type) {
        final isSelected = type == selected;
        return ChoiceChip(
          label: Text(_label(type)),
          avatar: Icon(
            _icon(type),
            size: 18,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          selected: isSelected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          side: isSelected
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
          onSelected: (_) => onSelected(type),
        );
      }).toList(),
    );
  }

  IconData _icon(TaskType type) => switch (type) {
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

  String _label(TaskType type) => switch (type) {
        TaskType.feeding => 'Feeding',
        TaskType.cleaning => 'Cleaning',
        TaskType.vaccination => 'Vaccination',
        TaskType.medicine => 'Medicine',
        TaskType.examination => 'Examination',
        TaskType.shedCheck => 'Shed Check',
        TaskType.eggCollection => 'Egg Collection',
        TaskType.waterCheck => 'Water Check',
        TaskType.biosecurity => 'Biosecurity',
        TaskType.other => 'Other',
      };
}
