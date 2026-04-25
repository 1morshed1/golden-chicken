import 'package:equatable/equatable.dart';

sealed class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => [];
}

final class InsightsRequested extends InsightsEvent {
  const InsightsRequested();
}

final class InsightAcknowledged extends InsightsEvent {
  const InsightAcknowledged(this.insightId);

  final String insightId;

  @override
  List<Object?> get props => [insightId];
}
