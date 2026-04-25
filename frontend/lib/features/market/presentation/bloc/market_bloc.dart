import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/market/domain/usecases/get_market_prices.dart';
import 'package:golden_chicken/features/market/domain/usecases/get_price_trend.dart';
import 'package:golden_chicken/features/market/presentation/bloc/market_event.dart';
import 'package:golden_chicken/features/market/presentation/bloc/market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc({
    required GetMarketPrices getMarketPrices,
    required GetPriceTrend getPriceTrend,
  })  : _getMarketPrices = getMarketPrices,
        _getPriceTrend = getPriceTrend,
        super(const MarketInitial()) {
    on<MarketDataRequested>(_onDataRequested);
    on<MarketPeriodChanged>(_onPeriodChanged);
  }

  final GetMarketPrices _getMarketPrices;
  final GetPriceTrend _getPriceTrend;

  Future<void> _onDataRequested(
    MarketDataRequested event,
    Emitter<MarketState> emit,
  ) async {
    emit(const MarketLoading());
    final result = await _getMarketPrices();
    await result.fold(
      (failure) async => emit(MarketError(failure.message)),
      (prices) async {
        var loaded = MarketLoaded(
          prices: prices,
          selectedPeriod: '7d',
        );
        emit(loaded);

        final eggTrend = await _getPriceTrend(product: 'egg', period: '7d');
        final meatTrend = await _getPriceTrend(product: 'meat', period: '7d');

        loaded = loaded.copyWith(
          eggTrend: eggTrend.getOrElse(() => []),
          meatTrend: meatTrend.getOrElse(() => []),
        );
        emit(loaded);
      },
    );
  }

  Future<void> _onPeriodChanged(
    MarketPeriodChanged event,
    Emitter<MarketState> emit,
  ) async {
    final current = state;
    if (current is! MarketLoaded) return;

    final eggTrend =
        await _getPriceTrend(product: 'egg', period: event.period);
    final meatTrend =
        await _getPriceTrend(product: 'meat', period: event.period);

    emit(current.copyWith(
      selectedPeriod: event.period,
      eggTrend: eggTrend.getOrElse(() => []),
      meatTrend: meatTrend.getOrElse(() => []),
    ));
  }
}
