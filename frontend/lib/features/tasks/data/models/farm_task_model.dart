import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';

class FarmTaskModel extends FarmTask {
  const FarmTaskModel({
    required super.id,
    required super.title,
    required super.type,
    required super.status,
    required super.dueDate,
    super.dueTime,
    super.recurrence,
    super.description,
    super.completedAt,
  });

  factory FarmTaskModel.fromJson(Map<String, dynamic> json) {
    return FarmTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _parseType(json['type'] as String?),
      status: _parseStatus(json['status'] as String?),
      dueDate: DateTime.parse(json['due_date'] as String),
      dueTime: json['due_time'] as String?,
      recurrence: _parseRecurrence(json['recurrence'] as String?),
      description: json['description'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type.name,
        'due_date': dueDate.toIso8601String().split('T').first,
        if (dueTime != null) 'due_time': dueTime,
        'recurrence': recurrence.name,
        if (description != null) 'description': description,
      };

  static TaskType _parseType(String? value) => switch (value) {
        'feeding' => TaskType.feeding,
        'cleaning' => TaskType.cleaning,
        'vaccination' => TaskType.vaccination,
        'inspection' => TaskType.inspection,
        _ => TaskType.other,
      };

  static TaskStatus _parseStatus(String? value) => switch (value) {
        'completed' => TaskStatus.completed,
        'overdue' => TaskStatus.overdue,
        _ => TaskStatus.pending,
      };

  static Recurrence _parseRecurrence(String? value) => switch (value) {
        'daily' => Recurrence.daily,
        'weekly' => Recurrence.weekly,
        'custom' => Recurrence.custom,
        _ => Recurrence.none,
      };
}
