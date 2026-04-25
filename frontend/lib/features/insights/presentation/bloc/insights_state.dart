import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/insights/domain/entities/farm_insight.dart';

sealed class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => [];
}

final class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

final class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

final class InsightsLoaded extends InsightsState {
  const InsightsLoaded({required this.insights});

  final List<FarmInsight> insights;

  List<FarmInsight> get activeInsights =>
      insights.where((i) => !i.isAcknowledged).toList();

  List<FarmInsight> get acknowledgedInsights =>
      insights.where((i) => i.isAcknowledged).toList();

  @override
  List<Object?> get props => [insights];
}

final class InsightsError extends InsightsState {
  const InsightsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
