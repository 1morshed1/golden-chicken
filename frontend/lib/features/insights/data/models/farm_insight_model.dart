import 'package:golden_chicken/features/insights/domain/entities/farm_insight.dart';

class FarmInsightModel extends FarmInsight {
  const FarmInsightModel({
    required super.id,
    required super.title,
    required super.description,
    required super.severity,
    super.action,
    super.isAcknowledged,
    super.createdAt,
  });

  factory FarmInsightModel.fromJson(Map<String, dynamic> json) {
    return FarmInsightModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: _parseSeverity(json['severity'] as String?),
      action: json['action'] as String?,
      isAcknowledged: (json['is_acknowledged'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  static InsightSeverity _parseSeverity(String? value) => switch (value) {
        'critical' => InsightSeverity.critical,
        'warning' => InsightSeverity.warning,
        _ => InsightSeverity.info,
      };
}
