import 'package:flutter/material.dart';
import 'package:golden_chicken/features/insights/domain/entities/farm_insight.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    required this.insight,
    this.onAcknowledge,
    super.key,
  });

  final FarmInsight insight;
  final VoidCallback? onAcknowledge;

  Color _severityColor(InsightSeverity severity) => switch (severity) {
        InsightSeverity.critical => Colors.red,
        InsightSeverity.warning => Colors.orange,
        InsightSeverity.info => Colors.blue,
      };

  IconData _severityIcon(InsightSeverity severity) => switch (severity) {
        InsightSeverity.critical => Icons.error,
        InsightSeverity.warning => Icons.warning_amber_rounded,
        InsightSeverity.info => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(insight.severity);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _severityIcon(insight.severity),
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (insight.isAcknowledged)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.description,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (insight.action != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          insight.action!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (!insight.isAcknowledged && onAcknowledge != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onAcknowledge,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Acknowledge'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
