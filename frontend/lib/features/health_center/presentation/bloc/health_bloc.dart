import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<HealthCategorySelected>(_onCategorySelected);
    on<HealthAskAiRequested>(_onAskAi);
  }

  final GetHealthTabs _getHealthTabs;
  final AskHealthQuestion _askHealthQuestion;
  String language = 'en';

  Future<void> _onTabsRequested(
    HealthTabsRequested event,
    Emitter<HealthState> emit,
  ) async {
    emit(const HealthLoading());
    final result = await _getHealthTabs();
    result.fold(
      (failure) => emit(HealthError(failure.message)),
      (items) => emit(HealthLoaded(items: items)),
    );
  }

  void _onCategorySelected(
    HealthCategorySelected event,
    Emitter<HealthState> emit,
  ) {
    final current = state;
    if (current is HealthLoaded) {
      emit(current.copyWith(selectedCategory: () => event.category));
    }
  }

  Future<void> _onAskAi(
    HealthAskAiRequested event,
    Emitter<HealthState> emit,
  ) async {
    final current = state;
    if (current is! HealthLoaded) return;

    emit(current.copyWith(isAskingAi: true, askAiError: () => null));

    final result = await _askHealthQuestion(
      tabId: event.tabId,
      language: language,
    );

    result.fold(
      (failure) {
        emit(current.copyWith(
          isAskingAi: false,
          askAiError: () => failure.message,
        ));
      },
      (sessionId) {
        _lastAskAiSessionId = sessionId;
        emit(current.copyWith(isAskingAi: false));
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
