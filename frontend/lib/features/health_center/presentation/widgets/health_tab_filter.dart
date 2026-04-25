import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_radius.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/core/l10n/l10n.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

class HealthTabFilter extends StatelessWidget {
  const HealthTabFilter({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final HealthTabType selected;
  final ValueChanged<HealthTabType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      (HealthTabType.diseases, l10n.diseases),
      (HealthTabType.vaccines, l10n.vaccines),
      (HealthTabType.emergency, l10n.emergency),
      (HealthTabType.diagnosis, l10n.diagnosis),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (type, label) = tabs[index];
          final isSelected = type == selected;

          return GestureDetector(
            onTap: () => onSelected(type),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
