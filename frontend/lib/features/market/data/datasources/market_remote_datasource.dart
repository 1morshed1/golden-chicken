import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/market/data/models/market_price_model.dart';

abstract class MarketRemoteDatasource {
  Future<List<MarketPriceModel>> getPrices();
  Future<MarketTipModel> getMarketTip();
  Future<List<PriceTrendPointModel>> getPriceTrend({
    required String product,
    required String period,
  });
}

class MarketRemoteDatasourceImpl implements MarketRemoteDatasource {
  const MarketRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<MarketPriceModel>> getPrices() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.marketPrices,
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => MarketPriceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MarketTipModel> getMarketTip() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.marketPrices}/tip',
    );
    return MarketTipModel.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<PriceTrendPointModel>> getPriceTrend({
    required String product,
    required String period,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.marketPrices}/trend',
      queryParameters: {'product': product, 'period': period},
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map(
          (e) => PriceTrendPointModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}
