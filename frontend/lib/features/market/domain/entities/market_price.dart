import 'package:equatable/equatable.dart';

class MarketPrice extends Equatable {
  const MarketPrice({
    required this.product,
    required this.price,
    required this.unit,
    required this.changePercent,
    this.updatedAt,
  });

  final String product;
  final double price;
  final String unit;
  final double changePercent;
  final DateTime? updatedAt;

  bool get isPositive => changePercent >= 0;

  @override
  List<Object?> get props => [product, price, unit, changePercent];
}

class MarketTip extends Equatable {
  const MarketTip({
    required this.message,
    required this.confidence,
  });

  final String message;
  final int confidence;

  @override
  List<Object?> get props => [message, confidence];
}

class PriceTrendPoint extends Equatable {
  const PriceTrendPoint({
    required this.date,
    required this.price,
  });

  final DateTime date;
  final double price;

  @override
  List<Object?> get props => [date, price];
}
