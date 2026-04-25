import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';
import 'package:golden_chicken/features/market/domain/repositories/market_repository.dart';

class GetPriceTrend {
  const GetPriceTrend(this._repository);

  final MarketRepository _repository;

  Future<Either<Failure, List<PriceTrendPoint>>> call({
    required String product,
    required String period,
  }) =>
      _repository.getPriceTrend(product: product, period: period);
}
