import 'package:equatable/equatable.dart';

enum Severity { critical, high, medium, low }

class HealthItem extends Equatable {
  const HealthItem({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.severity,
    required this.symptomCount,
    this.category,
    this.icon,
    this.description,
  });

  final String id;
  final String name;
  final String nameBn;
  final Severity severity;
  final int symptomCount;
  final String? category;
  final String? icon;
  final String? description;

  @override
  List<Object?> get props => [id, name, severity, symptomCount];
}
