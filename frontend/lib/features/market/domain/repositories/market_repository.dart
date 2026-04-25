import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<MarketPrice>>> getPrices();
  Future<Either<Failure, MarketTip>> getMarketTip();
  Future<Either<Failure, List<PriceTrendPoint>>> getPriceTrend({
    required String product,
    required String period,
  });
}
