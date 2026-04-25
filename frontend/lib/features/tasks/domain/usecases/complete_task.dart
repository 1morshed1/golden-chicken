import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';
import 'package:golden_chicken/features/tasks/domain/repositories/task_repository.dart';

class CompleteTask {
  const CompleteTask(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, FarmTask>> call(String taskId) =>
      _repository.completeTask(taskId);
}
