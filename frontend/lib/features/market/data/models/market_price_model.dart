import 'package:golden_chicken/features/market/domain/entities/market_price.dart';

class MarketPriceModel extends MarketPrice {
  const MarketPriceModel({
    required super.product,
    required super.price,
    required super.unit,
    required super.changePercent,
    super.updatedAt,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      product: json['product_name'] as String,
      price: (json['price_bdt'] as num).toDouble(),
      unit: (json['unit'] as String?) ?? 'unit',
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0,
      updatedAt: json['fetched_at'] != null
          ? DateTime.tryParse(json['fetched_at'] as String)
          : null,
    );
  }
}

class MarketTipModel extends MarketTip {
  const MarketTipModel({
    required super.message,
    required super.confidence,
  });

  factory MarketTipModel.fromJson(Map<String, dynamic> json) {
    return MarketTipModel(
      message: json['message'] as String,
      confidence: (json['confidence'] as num?)?.toInt() ?? 0,
    );
  }
}

class PriceTrendPointModel extends PriceTrendPoint {
  const PriceTrendPointModel({
    required super.date,
    required super.price,
  });

  factory PriceTrendPointModel.fromJson(Map<String, dynamic> json) {
    return PriceTrendPointModel(
      date: DateTime.parse(json['date'] as String),
      price: (json['price_bdt'] as num).toDouble(),
    );
  }
}
