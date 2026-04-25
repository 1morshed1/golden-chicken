import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

final class TaskInitial extends TaskState {
  const TaskInitial();
}

final class TaskLoading extends TaskState {
  const TaskLoading();
}

final class TasksLoaded extends TaskState {
  const TasksLoaded({required this.tasks});

  final List<FarmTask> tasks;

  List<FarmTask> get overdue =>
      tasks.where((t) => t.isOverdue).toList();

  List<FarmTask> get today {
    final now = DateTime.now();
    return tasks
        .where(
          (t) =>
              !t.isOverdue &&
              t.status != TaskStatus.completed &&
              t.dueDate.year == now.year &&
              t.dueDate.month == now.month &&
              t.dueDate.day == now.day,
        )
        .toList();
  }

  List<FarmTask> get completed =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();

  List<FarmTask> get upcoming =>
      tasks
          .where(
            (t) =>
                t.status == TaskStatus.pending &&
                !t.isOverdue &&
                !today.contains(t),
          )
          .toList();

  @override
  List<Object?> get props => [tasks];
}

final class TaskError extends TaskState {
  const TaskError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class TaskSaving extends TaskState {
  const TaskSaving();
}

final class TaskSaved extends TaskState {
  const TaskSaved();
}
