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
    super.priority,
    super.description,
    super.completedAt,
  });

  factory FarmTaskModel.fromJson(Map<String, dynamic> json) {
    return FarmTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: _parseType(json['task_type'] as String?),
      status: json['is_completed'] == true
          ? TaskStatus.completed
          : TaskStatus.pending,
      dueDate: DateTime.parse(json['due_date'] as String),
      dueTime: json['due_time'] as String?,
      recurrence: _parseRecurrence(json['recurrence'] as String?),
      priority: (json['priority'] as num?)?.toInt() ?? 5,
      description: json['description'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'task_type': _typeToString(type),
        'due_date': dueDate.toIso8601String().split('T').first,
        if (dueTime != null) 'due_time': dueTime,
        'recurrence': recurrence.name,
        'priority': priority,
        if (description != null) 'description': description,
      };

  static TaskType _parseType(String? value) => switch (value) {
        'feeding' => TaskType.feeding,
        'vaccination' => TaskType.vaccination,
        'medicine' => TaskType.medicine,
        'cleaning' => TaskType.cleaning,
        'examination' => TaskType.examination,
        'shed_check' => TaskType.shedCheck,
        'egg_collection' => TaskType.eggCollection,
        'water_check' => TaskType.waterCheck,
        'biosecurity' => TaskType.biosecurity,
        _ => TaskType.other,
      };

  static String _typeToString(TaskType type) => switch (type) {
        TaskType.feeding => 'feeding',
        TaskType.vaccination => 'vaccination',
        TaskType.medicine => 'medicine',
        TaskType.cleaning => 'cleaning',
        TaskType.examination => 'examination',
        TaskType.shedCheck => 'shed_check',
        TaskType.eggCollection => 'egg_collection',
        TaskType.waterCheck => 'water_check',
        TaskType.biosecurity => 'biosecurity',
        TaskType.other => 'other',
      };

  static Recurrence _parseRecurrence(String? value) => switch (value) {
        'daily' => Recurrence.daily,
        'weekly' => Recurrence.weekly,
        'monthly' => Recurrence.monthly,
        'custom' => Recurrence.custom,
        _ => Recurrence.none,
      };
}
