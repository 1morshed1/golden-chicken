import 'package:equatable/equatable.dart';

sealed class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

final class MarketDataRequested extends MarketEvent {
  const MarketDataRequested();
}

final class MarketPeriodChanged extends MarketEvent {
  const MarketPeriodChanged(this.period);
  final String period;

  @override
  List<Object?> get props => [period];
}
