import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

class HealthItemModel extends HealthItem {
  const HealthItemModel({
    required super.id,
    required super.name,
    required super.nameBn,
    required super.severity,
    required super.symptomCount,
    super.category,
    super.icon,
    super.description,
  });

  factory HealthItemModel.fromJson(Map<String, dynamic> json) {
    return HealthItemModel(
      id: json['id'] as String,
      name: (json['disease_name_en'] ?? json['name'] ?? '') as String,
      nameBn: (json['disease_name_bn'] ?? json['name_bn'] ?? '') as String,
      severity: _parseSeverity(json['severity'] as String?),
      symptomCount: (json['symptom_count'] as num?)?.toInt() ?? 0,
      category: json['category'] as String?,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  static Severity _parseSeverity(String? value) => switch (value) {
        'critical' => Severity.critical,
        'high' => Severity.high,
        'medium' => Severity.medium,
        _ => Severity.low,
      };
}
