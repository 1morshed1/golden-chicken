import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/health_center/data/datasources/health_remote_datasource.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';
import 'package:golden_chicken/features/health_center/domain/repositories/health_repository.dart';

class HealthRepositoryImpl implements HealthRepository {
  const HealthRepositoryImpl({required HealthRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  final HealthRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<HealthItem>>> getHealthItems() async {
    try {
      final items = await _remote.getHealthItems();
      return Right(items);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> askHealthQuestion({
    required String tabId,
    required String language,
  }) async {
    try {
      final data = await _remote.askHealthQuestion(
        tabId: tabId,
        language: language,
      );
      final session = data['session'] as Map<String, dynamic>;
      return Right(session['id'] as String);
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
