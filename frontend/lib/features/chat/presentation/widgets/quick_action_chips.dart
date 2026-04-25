import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';

class QuickActionChips extends StatelessWidget {
  const QuickActionChips({this.onChipTapped, super.key});

  final ValueChanged<String>? onChipTapped;

  static const _actions = [
    _QuickAction(
      label: 'আজকের খাদ্য পরিকল্পনা?',
      icon: Icons.restaurant,
    ),
    _QuickAction(
      label: 'রোগের প্রথম পরীক্ষা',
      icon: Icons.health_and_safety,
    ),
    _QuickAction(
      label: 'বাজার মূল্য',
      icon: Icons.trending_up,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _actions
          .map(
            (action) => ActionChip(
              avatar: Icon(action.icon, size: 18, color: AppColors.primary),
              label: Text(
                action.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              onPressed: () => onChipTapped?.call(action.label),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.label, required this.icon});
  final String label;
  final IconData icon;
}
