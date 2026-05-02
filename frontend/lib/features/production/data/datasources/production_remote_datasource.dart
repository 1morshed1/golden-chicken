import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/production/data/models/chicken_record_model.dart';
import 'package:golden_chicken/features/production/data/models/egg_record_model.dart';
import 'package:golden_chicken/features/production/data/models/flock_summary_model.dart';
import 'package:golden_chicken/features/production/data/models/shed_model.dart';

abstract class ProductionRemoteDatasource {
  Future<List<ShedModel>> getSheds(String farmId);
  Future<FlockSummaryModel> getFlockOverview();
  Future<List<EggRecordModel>> getEggRecords(String shedId);
  Future<EggRecordModel> addEggRecord(String shedId, EggRecordModel record);
  Future<List<ChickenRecordModel>> getChickenRecords(String shedId);
  Future<ChickenRecordModel> addChickenRecord(
    String shedId,
    ChickenRecordModel record,
  );
}

class ProductionRemoteDatasourceImpl implements ProductionRemoteDatasource {
  const ProductionRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ShedModel>> getSheds(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.farmSheds(farmId),
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => ShedModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FlockSummaryModel> getFlockOverview() async {
    final farmsResponse = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.farms,
    );
    final farms = farmsResponse.data!['data'] as List<dynamic>;

    var totalBirds = 0;
    var totalAge = 0;
    var shedCount = 0;
    final allAlerts = <Map<String, dynamic>>[];

    for (final farm in farms) {
      final farmMap = farm as Map<String, dynamic>;
      final farmId = farmMap['id'] as String;
      final shedsResponse = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.farmSheds(farmId),
      );
      final sheds = shedsResponse.data!['data'] as List<dynamic>;
      for (final shed in sheds) {
        final s = shed as Map<String, dynamic>;
        final birdCount = (s['bird_count'] as num?)?.toInt() ?? 0;
        final ageDays = (s['bird_age_days'] as num?)?.toInt();
        totalBirds += birdCount;
        if (ageDays != null && birdCount > 0) {
          totalAge += ageDays;
          shedCount++;
        }
        if (s['status'] == 'needs_attention') {
          allAlerts.add({
            'id': s['id'],
            'title': '${s['name']} needs attention',
            'type': 'warning',
          });
        }
      }
    }

    final avgAge = shedCount > 0 ? (totalAge / shedCount).round() : 0;

    return FlockSummaryModel.fromJson({
      'total_birds': totalBirds,
      'alert_count': allAlerts.length,
      'avg_age_days': avgAge,
      'ai_score': totalBirds > 0 ? 78 : 0,
      'alerts': allAlerts,
      'feed_plan': totalBirds > 0
          ? [
              {'name': 'Starter Feed', 'amount_kg': (totalBirds * 0.05).round()},
              {'name': 'Grower Feed', 'amount_kg': (totalBirds * 0.08).round()},
              {'name': 'Calcium Supplement', 'amount_kg': (totalBirds * 0.01).round()},
            ]
          : <Map<String, dynamic>>[],
      'last_updated': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<EggRecordModel>> getEggRecords(String shedId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.eggRecords(shedId),
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => EggRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EggRecordModel> addEggRecord(
    String shedId,
    EggRecordModel record,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.eggRecords(shedId),
      data: record.toJson(),
    );
    return EggRecordModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ChickenRecordModel>> getChickenRecords(String shedId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.chickenRecords(shedId),
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => ChickenRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChickenRecordModel> addChickenRecord(
    String shedId,
    ChickenRecordModel record,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.chickenRecords(shedId),
      data: record.toJson(),
    );
    return ChickenRecordModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }
}
