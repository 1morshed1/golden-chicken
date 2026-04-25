import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';
import 'package:golden_chicken/features/live_ai/domain/repositories/live_ai_repository.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_event.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_state.dart';

class LiveAiBloc extends Bloc<LiveAiEvent, LiveAiState> {
  LiveAiBloc({
    required LiveAiRepository repository,
    required FlutterSecureStorage secureStorage,
  })  : _repository = repository,
        _secureStorage = secureStorage,
        super(const LiveAiState()) {
    on<LiveAiStartRequested>(_onStart);
    on<LiveAiStopRequested>(_onStop);
    on<LiveAiMessageReceived>(_onMessageReceived);
    on<LiveAiErrorOccurred>(_onError);
    on<LiveAiTextSent>(_onTextSent);
  }

  final LiveAiRepository _repository;
  final FlutterSecureStorage _secureStorage;
  StreamSubscription<LiveAiMessage>? _subscription;

  Future<void> _onStart(
    LiveAiStartRequested event,
    Emitter<LiveAiState> emit,
  ) async {
    emit(state.copyWith(
      status: LiveSessionStatus.connecting,
      inputTranscript: '',
      outputTranscript: '',
    ));

    final token = await _secureStorage.read(key: 'access_token');
    if (token == null) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        errorMessage: 'Not authenticated',
      ));
      return;
    }

    try {
      final stream = _repository.connect(token);
      _subscription = stream.listen(
        (message) => add(LiveAiMessageReceived(message)),
        onError: (Object error) =>
            add(LiveAiErrorOccurred(error.toString())),
        onDone: () => add(const LiveAiStopRequested()),
      );
    } on Exception catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStop(
    LiveAiStopRequested event,
    Emitter<LiveAiState> emit,
  ) async {
    _repository.endSession();
    await _subscription?.cancel();
    _subscription = null;
    _repository.disconnect();
    emit(state.copyWith(status: LiveSessionStatus.idle));
  }

  void _onMessageReceived(
    LiveAiMessageReceived event,
    Emitter<LiveAiState> emit,
  ) {
    final msg = event.message;
    switch (msg.type) {
      case LiveMessageType.sessionStarted:
        emit(state.copyWith(status: LiveSessionStatus.listening));
      case LiveMessageType.inputTranscript:
        emit(state.copyWith(inputTranscript: msg.text ?? ''));
      case LiveMessageType.outputTranscript:
        emit(state.copyWith(
          status: LiveSessionStatus.aiSpeaking,
          outputTranscript: msg.text ?? '',
        ));
      case LiveMessageType.turnComplete:
        emit(state.copyWith(status: LiveSessionStatus.listening));
      case LiveMessageType.warning:
        emit(state.copyWith(errorMessage: msg.text));
      case LiveMessageType.error:
        emit(state.copyWith(
          status: LiveSessionStatus.error,
          errorMessage: msg.text ?? 'Session error',
        ));
      case LiveMessageType.audio:
        break;
    }
  }

  void _onError(
    LiveAiErrorOccurred event,
    Emitter<LiveAiState> emit,
  ) {
    emit(state.copyWith(
      status: LiveSessionStatus.error,
      errorMessage: event.error,
    ));
  }

  void _onTextSent(
    LiveAiTextSent event,
    Emitter<LiveAiState> emit,
  ) {
    _repository.sendText(event.text);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _repository.disconnect();
    return super.close();
  }
}
