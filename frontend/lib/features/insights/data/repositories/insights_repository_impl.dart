import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/insights/data/datasources/insights_remote_datasource.dart';
import 'package:golden_chicken/features/insights/domain/entities/farm_insight.dart';
import 'package:golden_chicken/features/insights/domain/repositories/insights_repository.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  const InsightsRepositoryImpl(
      {required InsightsRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  final InsightsRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<FarmInsight>>> getInsights() async {
    try {
      final insights = await _remote.getInsights();
      return Right(insights);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, void>> acknowledgeInsight(String insightId) async {
    try {
      await _remote.acknowledgeInsight(insightId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return ServerFailure(
      e.response?.data is Map<String, dynamic>
          ? ((e.response!.data as Map<String, dynamic>)['detail']
                  as String?) ??
              'Server error'
          : 'Server error',
    );
  }
}
