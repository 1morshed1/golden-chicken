import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/insights/domain/usecases/acknowledge_insight.dart';
import 'package:golden_chicken/features/insights/domain/usecases/get_insights.dart';
import 'package:golden_chicken/features/insights/presentation/bloc/insights_event.dart';
import 'package:golden_chicken/features/insights/presentation/bloc/insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  InsightsBloc({
    required GetInsights getInsights,
    required AcknowledgeInsight acknowledgeInsight,
  })  : _getInsights = getInsights,
        _acknowledgeInsight = acknowledgeInsight,
        super(const InsightsInitial()) {
    on<InsightsRequested>(_onInsightsRequested);
    on<InsightAcknowledged>(_onInsightAcknowledged);
  }

  final GetInsights _getInsights;
  final AcknowledgeInsight _acknowledgeInsight;

  Future<void> _onInsightsRequested(
    InsightsRequested event,
    Emitter<InsightsState> emit,
  ) async {
    emit(const InsightsLoading());
    final result = await _getInsights();
    result.fold(
      (failure) => emit(InsightsError(failure.message)),
      (insights) => emit(InsightsLoaded(insights: insights)),
    );
  }

  Future<void> _onInsightAcknowledged(
    InsightAcknowledged event,
    Emitter<InsightsState> emit,
  ) async {
    final result = await _acknowledgeInsight(event.insightId);
    result.fold(
      (failure) => emit(InsightsError(failure.message)),
      (_) => add(const InsightsRequested()),
    );
  }
}
