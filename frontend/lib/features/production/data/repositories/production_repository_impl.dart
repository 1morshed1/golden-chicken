import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/production/data/datasources/production_remote_datasource.dart';
import 'package:golden_chicken/features/production/data/models/chicken_record_model.dart';
import 'package:golden_chicken/features/production/data/models/egg_record_model.dart';
import 'package:golden_chicken/features/production/domain/entities/chicken_record.dart';
import 'package:golden_chicken/features/production/domain/entities/egg_record.dart';
import 'package:golden_chicken/features/production/domain/entities/flock_summary.dart';
import 'package:golden_chicken/features/production/domain/entities/shed.dart';
import 'package:golden_chicken/features/production/domain/repositories/production_repository.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  const ProductionRepositoryImpl({
    required ProductionRemoteDatasource remoteDatasource,
  }) : _remote = remoteDatasource;

  final ProductionRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<Shed>>> getSheds(String farmId) async {
    try {
      final sheds = await _remote.getSheds(farmId);
      return Right(sheds);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, FlockSummary>> getFlockOverview() async {
    try {
      final summary = await _remote.getFlockOverview();
      return Right(summary);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EggRecord>>> getEggRecords(
    String shedId,
  ) async {
    try {
      final records = await _remote.getEggRecords(shedId);
      return Right(records);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, EggRecord>> addEggRecord({
    required String shedId,
    required DateTime date,
    required int totalEggs,
    int brokenEggs = 0,
    int soldEggs = 0,
    String? notes,
  }) async {
    try {
      final model = EggRecordModel(
        id: '',
        shedId: shedId,
        date: date,
        totalEggs: totalEggs,
        brokenEggs: brokenEggs,
        soldEggs: soldEggs,
        notes: notes,
      );
      final result = await _remote.addEggRecord(shedId, model);
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, List<ChickenRecord>>> getChickenRecords(
    String shedId,
  ) async {
    try {
      final records = await _remote.getChickenRecords(shedId);
      return Right(records);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, ChickenRecord>> addChickenRecord({
    required String shedId,
    required DateTime date,
    required int totalBirds,
    int additions = 0,
    int mortality = 0,
    String? notes,
  }) async {
    try {
      final model = ChickenRecordModel(
        id: '',
        shedId: shedId,
        date: date,
        totalBirds: totalBirds,
        additions: additions,
        mortality: mortality,
        notes: notes,
      );
      final result = await _remote.addChickenRecord(shedId, model);
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
