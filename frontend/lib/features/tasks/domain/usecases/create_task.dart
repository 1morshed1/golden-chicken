import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';
import 'package:golden_chicken/features/tasks/domain/repositories/task_repository.dart';

class CreateTask {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, FarmTask>> call({
    required String title,
    required TaskType type,
    required DateTime dueDate,
    String? dueTime,
    Recurrence recurrence = Recurrence.none,
    String? description,
  }) =>
      _repository.createTask(
        title: title,
        type: type,
        dueDate: dueDate,
        dueTime: dueTime,
        recurrence: recurrence,
        description: description,
      );
}
