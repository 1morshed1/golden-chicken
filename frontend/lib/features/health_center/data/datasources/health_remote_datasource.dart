import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/health_center/data/models/health_tab_model.dart';

abstract class HealthRemoteDatasource {
  Future<List<HealthTabModel>> getHealthTabs();
  Future<String> askHealthQuestion({
    required String tabId,
    required String question,
  });
}

class HealthRemoteDatasourceImpl implements HealthRemoteDatasource {
  const HealthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<HealthTabModel>> getHealthTabs() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.healthTabs,
    );

    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => HealthTabModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> askHealthQuestion({
    required String tabId,
    required String question,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.askHealth(tabId),
      data: {'question': question},
    );

    return response.data!['session_id'] as String;
  }
}
