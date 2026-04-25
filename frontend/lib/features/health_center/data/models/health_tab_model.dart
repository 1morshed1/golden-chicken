import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';

class HealthItemModel extends HealthItem {
  const HealthItemModel({
    required super.id,
    required super.name,
    required super.nameBn,
    required super.severity,
    required super.symptomCount,
    super.icon,
    super.description,
  });

  factory HealthItemModel.fromJson(Map<String, dynamic> json) {
    return HealthItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameBn: (json['name_bn'] ?? json['name']) as String,
      severity: _parseSeverity(json['severity'] as String?),
      symptomCount: (json['symptom_count'] as num?)?.toInt() ?? 0,
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

class HealthTabModel extends HealthTab {
  const HealthTabModel({
    required super.id,
    required super.name,
    required super.nameBn,
    required super.type,
    required super.items,
  });

  factory HealthTabModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map(
              (e) => HealthItemModel.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return HealthTabModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameBn: (json['name_bn'] ?? json['name']) as String,
      type: _parseType(json['type'] as String?),
      items: items,
    );
  }

  static HealthTabType _parseType(String? value) => switch (value) {
        'vaccines' => HealthTabType.vaccines,
        'emergency' => HealthTabType.emergency,
        'diagnosis' => HealthTabType.diagnosis,
        _ => HealthTabType.diseases,
      };
}
