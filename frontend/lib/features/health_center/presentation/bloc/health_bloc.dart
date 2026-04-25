import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/health_center/domain/entities/health_tab.dart';
import 'package:golden_chicken/features/health_center/domain/usecases/ask_health_question.dart';
import 'package:golden_chicken/features/health_center/domain/usecases/get_health_tabs.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_event.dart';
import 'package:golden_chicken/features/health_center/presentation/bloc/health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc({
    required GetHealthTabs getHealthTabs,
    required AskHealthQuestion askHealthQuestion,
  })  : _getHealthTabs = getHealthTabs,
        _askHealthQuestion = askHealthQuestion,
        super(const HealthInitial()) {
    on<HealthTabsRequested>(_onTabsRequested);
    on<HealthTabSelected>(_onTabSelected);
    on<HealthSearchChanged>(_onSearchChanged);
    on<HealthAskAiRequested>(_onAskAi);
  }

  final GetHealthTabs _getHealthTabs;
  final AskHealthQuestion _askHealthQuestion;

  Future<void> _onTabsRequested(
    HealthTabsRequested event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    final result = await _getHealthTabs();
    result.fold(
      (failure) => emit(HealthError(failure.message)),
      (tabs) {
        emit(HealthLoaded(
          tabs: tabs,
          selectedType: HealthTabType.diseases,
        ));
      },
    );
  }

  void _onTabSelected(
    HealthTabSelected event,
    Emitter<HealthState> emit,
  ) {
    final current = state;
    if (current is HealthLoaded) {
      emit(current.copyWith(selectedType: event.type, searchQuery: ''));
    }
  }

  void _onSearchChanged(
    HealthSearchChanged event,
    Emitter<HealthState> emit,
  ) {
    final current = state;
    if (current is HealthLoaded) {
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onAskAi(
    HealthAskAiRequested event,
    Emitter<HealthState> emit,
  ) async {
    final previousState = state;
    emit(const HealthAskAiLoading());

    final question = 'Tell me about ${event.itemName}';
    final result = await _askHealthQuestion(
      tabId: event.tabId,
      question: question,
    );

    result.fold(
      (failure) {
        if (previousState is HealthLoaded) {
          emit(previousState);
        } else {
          emit(HealthError(failure.message));
        }
      },
      (sessionId) {
        _lastAskAiSessionId = sessionId;
        if (previousState is HealthLoaded) {
          emit(previousState);
        }
      },
    );
  }

  String? _lastAskAiSessionId;
  String? consumeAskAiSessionId() {
    final id = _lastAskAiSessionId;
    _lastAskAiSessionId = null;
    return id;
  }
}
