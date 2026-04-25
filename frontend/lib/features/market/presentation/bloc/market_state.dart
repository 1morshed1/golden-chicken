import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/market/domain/entities/market_price.dart';

sealed class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

final class MarketInitial extends MarketState {
  const MarketInitial();
}

final class MarketLoading extends MarketState {
  const MarketLoading();
}

final class MarketLoaded extends MarketState {
  const MarketLoaded({
    required this.prices,
    required this.selectedPeriod,
    this.tip,
    this.eggTrend = const [],
    this.meatTrend = const [],
  });

  final List<MarketPrice> prices;
  final String selectedPeriod;
  final MarketTip? tip;
  final List<PriceTrendPoint> eggTrend;
  final List<PriceTrendPoint> meatTrend;

  MarketLoaded copyWith({
    List<MarketPrice>? prices,
    String? selectedPeriod,
    MarketTip? tip,
    List<PriceTrendPoint>? eggTrend,
    List<PriceTrendPoint>? meatTrend,
  }) =>
      MarketLoaded(
        prices: prices ?? this.prices,
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        tip: tip ?? this.tip,
        eggTrend: eggTrend ?? this.eggTrend,
        meatTrend: meatTrend ?? this.meatTrend,
      );

  @override
  List<Object?> get props =>
      [prices, selectedPeriod, tip, eggTrend, meatTrend];
}

final class MarketError extends MarketState {
  const MarketError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
