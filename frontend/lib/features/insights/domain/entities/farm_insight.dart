import 'package:equatable/equatable.dart';

enum InsightSeverity { critical, warning, info }

class FarmInsight extends Equatable {
  const FarmInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.action,
    this.isAcknowledged = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final InsightSeverity severity;
  final String? action;
  final bool isAcknowledged;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, title, severity, isAcknowledged];
}
