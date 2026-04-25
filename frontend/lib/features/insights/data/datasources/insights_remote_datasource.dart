import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/insights/data/models/farm_insight_model.dart';

abstract class InsightsRemoteDatasource {
  Future<List<FarmInsightModel>> getInsights();
  Future<void> acknowledgeInsight(String insightId);
}

class InsightsRemoteDatasourceImpl implements InsightsRemoteDatasource {
  const InsightsRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<FarmInsightModel>> getInsights() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.insights,
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => FarmInsightModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> acknowledgeInsight(String insightId) async {
    await _dio.patch<void>('${ApiEndpoints.insights}/$insightId/acknowledge');
  }
}
