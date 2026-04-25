import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:golden_chicken/features/tasks/data/models/farm_task_model.dart';
import 'package:golden_chicken/features/tasks/domain/entities/farm_task.dart';
import 'package:golden_chicken/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({required TaskRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  final TaskRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<FarmTask>>> getTasks() async {
    try {
      final tasks = await _remote.getTasks();
      return Right(tasks);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, FarmTask>> createTask({
    required String title,
    required TaskType type,
    required DateTime dueDate,
    String? dueTime,
    Recurrence recurrence = Recurrence.none,
    String? description,
  }) async {
    try {
      final model = FarmTaskModel(
        id: '',
        title: title,
        type: type,
        status: TaskStatus.pending,
        dueDate: dueDate,
        dueTime: dueTime,
        recurrence: recurrence,
        description: description,
      );
      final result = await _remote.createTask(model);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, FarmTask>> completeTask(String taskId) async {
    try {
      final result = await _remote.completeTask(taskId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return const AuthFailure();
    return ServerFailure(
      e.response?.data is Map<String, dynamic>
          ? ((e.response!.data as Map<String, dynamic>)['detail'] as String?) ??
              'Server error'
          : 'Server error',
    );
  }
}
