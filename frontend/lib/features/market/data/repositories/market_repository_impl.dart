import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/market/data/datasources/market_remote_datasource.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';
import 'package:golden_chicken/features/market/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  const MarketRepositoryImpl({required MarketRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  final MarketRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<MarketPrice>>> getPrices() async {
    try {
      final prices = await _remote.getPrices();
      return Right(prices);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarketTip>> getMarketTip() async {
    try {
      final tip = await _remote.getMarketTip();
      return Right(tip);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PriceTrendPoint>>> getPriceTrend({
    required String product,
    required String period,
  }) async {
    try {
      final trend = await _remote.getPriceTrend(
        product: product,
        period: period,
      );
      return Right(trend);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
