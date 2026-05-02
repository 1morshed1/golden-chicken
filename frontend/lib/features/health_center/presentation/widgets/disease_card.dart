import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:golden_chicken/core/constants/app_spacing.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

class DiseaseCard extends StatelessWidget {
  const DiseaseCard({
    required this.item,
    required this.onAskAi,
    super.key,
  });

  final HealthItem item;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(item.severity);
    final severityLabel = _severityLabel(item.severity);
    final locale = Localizations.localeOf(context).languageCode;
    final displayName = locale == 'bn' ? item.nameBn : item.name;
    final displayNameSecondary = locale == 'bn' ? item.name : item.nameBn;
    final iconData = _diseaseIcon(item.icon);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconData.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    iconData.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  severityLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            displayName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            displayNameSecondary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '${item.symptomCount} symptoms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onAskAi,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ask AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor(Severity severity) => switch (severity) {
        Severity.critical => AppColors.severityCritical,
        Severity.high => AppColors.severityHigh,
        Severity.medium => AppColors.severityMedium,
        Severity.low => AppColors.severityLow,
      };

  String _severityLabel(Severity severity) => switch (severity) {
        Severity.critical => 'Critical',
        Severity.high => 'High',
        Severity.medium => 'Medium',
        Severity.low => 'Low',
      };

  _DiseaseIconData _diseaseIcon(String? icon) {
    return switch (icon) {
      'virus' => const _DiseaseIconData('🦠', Color(0xFFE8F5E9)),
      'warning' || 'alert' => const _DiseaseIconData('⚠️', Color(0xFFFFF8E1)),
      'bacteria' => const _DiseaseIconData('🔬', Color(0xFFE3F2FD)),
      'pill' || 'medicine' => const _DiseaseIconData('💊', Color(0xFFFCE4EC)),
      'bug' => const _DiseaseIconData('🐛', Color(0xFFFFF3E0)),
      'shield' => const _DiseaseIconData('🛡️', Color(0xFFE8EAF6)),
      'syringe' || 'vaccine' => const _DiseaseIconData('💉', Color(0xFFE0F7FA)),
      'thermometer' => const _DiseaseIconData('🌡️', Color(0xFFFFEBEE)),
      _ => const _DiseaseIconData('🦠', Color(0xFFE8F5E9)),
    };
  }
}

class _DiseaseIconData {
  const _DiseaseIconData(this.emoji, this.bgColor);
  final String emoji;
  final Color bgColor;
}
