import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/health_center/data/models/health_tab_model.dart';

abstract class HealthRemoteDatasource {
  Future<List<HealthItemModel>> getHealthItems();
  Future<Map<String, dynamic>> askHealthQuestion({
    required String tabId,
    required String language,
    String? additionalContext,
  });
}

class HealthRemoteDatasourceImpl implements HealthRemoteDatasource {
  const HealthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<HealthItemModel>> getHealthItems() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.healthTabs,
    );

    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => HealthItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> askHealthQuestion({
    required String tabId,
    required String language,
    String? additionalContext,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.askHealth(tabId),
      data: {
        'health_tab_id': tabId,
        'language': language,
        if (additionalContext != null) 'additional_context': additionalContext,
      },
      options: Options(receiveTimeout: const Duration(seconds: 90)),
    );

    return response.data!['data'] as Map<String, dynamic>;
  }
}
