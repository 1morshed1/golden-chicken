import 'package:equatable/equatable.dart';

enum HealthTabType { diseases, vaccines, emergency, diagnosis }

enum Severity { critical, high, medium, low }

class HealthTab extends Equatable {
  const HealthTab({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.type,
    required this.items,
  });

  final String id;
  final String name;
  final String nameBn;
  final HealthTabType type;
  final List<HealthItem> items;

  @override
  List<Object?> get props => [id, name, type, items];
}

class HealthItem extends Equatable {
  const HealthItem({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.severity,
    required this.symptomCount,
    this.icon,
    this.description,
  });

  final String id;
  final String name;
  final String nameBn;
  final Severity severity;
  final int symptomCount;
  final String? icon;
  final String? description;

  @override
  List<Object?> get props => [id, name, severity, symptomCount];
}
