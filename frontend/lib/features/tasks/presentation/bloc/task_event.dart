import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

final class TasksRequested extends TaskEvent {
  const TasksRequested();
}

final class TaskCompleted extends TaskEvent {
  const TaskCompleted(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

final class TaskCreated extends TaskEvent {
  const TaskCreated({
    required this.title,
    required this.type,
    required this.dueDate,
    this.dueTime,
    this.recurrence = Recurrence.none,
    this.description,
  });

  final String title;
  final TaskType type;
  final DateTime dueDate;
  final String? dueTime;
  final Recurrence recurrence;
  final String? description;

  @override
  List<Object?> get props => [title, type, dueDate, recurrence];
}
