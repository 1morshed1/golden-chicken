import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/tasks/data/models/farm_task_model.dart';

abstract class TaskRemoteDatasource {
  Future<List<FarmTaskModel>> getTasks();
  Future<FarmTaskModel> createTask(FarmTaskModel task);
  Future<FarmTaskModel> completeTask(String taskId);
}

class TaskRemoteDatasourceImpl implements TaskRemoteDatasource {
  const TaskRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FarmTaskModel>> getTasks() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.tasks,
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => FarmTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FarmTaskModel> createTask(FarmTaskModel task) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.tasks,
      data: task.toJson(),
    );
    return FarmTaskModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<FarmTaskModel> completeTask(String taskId) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tasks}/$taskId/complete',
    );
    return FarmTaskModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
