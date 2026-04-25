import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<FarmTask>>> getTasks();

  Future<Either<Failure, FarmTask>> createTask({
    required String title,
    required TaskType type,
    required DateTime dueDate,
    String? dueTime,
    Recurrence recurrence = Recurrence.none,
    String? description,
  });

  Future<Either<Failure, FarmTask>> completeTask(String taskId);
}
