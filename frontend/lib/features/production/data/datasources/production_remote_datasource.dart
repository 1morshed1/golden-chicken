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
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.farms,
    );
    return FlockSummaryModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
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
