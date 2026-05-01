import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:golden_chicken/core/services/audio_player_service.dart';
import 'package:golden_chicken/core/services/audio_recorder_service.dart';
import 'package:golden_chicken/core/services/camera_frame_service.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';
import 'package:golden_chicken/features/live_ai/domain/repositories/live_ai_repository.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_event.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_state.dart';

class LiveAiBloc extends Bloc<LiveAiEvent, LiveAiState> {
  LiveAiBloc({
    required LiveAiRepository repository,
    required FlutterSecureStorage secureStorage,
    required AudioRecorderService audioRecorder,
    required AudioPlayerService audioPlayer,
    required CameraFrameService cameraFrameService,
  })  : _repository = repository,
        _secureStorage = secureStorage,
        _audioRecorder = audioRecorder,
        _audioPlayer = audioPlayer,
        _cameraFrameService = cameraFrameService,
        super(const LiveAiState()) {
    on<LiveAiStartRequested>(_onStart);
    on<LiveAiStopRequested>(_onStop);
    on<LiveAiMessageReceived>(_onMessageReceived);
    on<LiveAiErrorOccurred>(_onError);
    on<LiveAiTextSent>(_onTextSent);
    on<LiveAiCameraToggled>(_onCameraToggled);
  }

  final LiveAiRepository _repository;
  final FlutterSecureStorage _secureStorage;
  final AudioRecorderService _audioRecorder;
  final AudioPlayerService _audioPlayer;
  final CameraFrameService _cameraFrameService;
  StreamSubscription<LiveAiMessage>? _wsSubscription;
  StreamSubscription<List<int>>? _audioStreamSubscription;

  CameraFrameService get cameraFrameService => _cameraFrameService;

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

    final hasMicPermission = await _audioRecorder.hasPermission();
    if (!hasMicPermission) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        errorMessage: 'Microphone permission is required',
      ));
      return;
    }

    try {
      final stream = _repository.connect(token);
      _wsSubscription = stream.listen(
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

  Future<void> _startAudioCapture() async {
    try {
      final audioStream = await _audioRecorder.startRecording();
      _audioStreamSubscription = audioStream.listen(
        _repository.sendAudio,
      );
    } on Exception catch (e) {
      add(LiveAiErrorOccurred('Microphone error: $e'));
    }
  }

  Future<void> _stopAudioCapture() async {
    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;
    await _audioRecorder.stopRecording();
  }

  Future<void> _onStop(
    LiveAiStopRequested event,
    Emitter<LiveAiState> emit,
  ) async {
    _repository.endSession();
    await _stopAudioCapture();
    await _audioPlayer.stop();
    _cameraFrameService.stopCapturing();
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    _repository.disconnect();
    emit(state.copyWith(
      status: LiveSessionStatus.idle,
      isCameraActive: false,
    ));
  }

  Future<void> _onMessageReceived(
    LiveAiMessageReceived event,
    Emitter<LiveAiState> emit,
  ) async {
    final msg = event.message;
    switch (msg.type) {
      case LiveMessageType.sessionStarted:
        emit(state.copyWith(status: LiveSessionStatus.listening));
        await _startAudioCapture();
      case LiveMessageType.inputTranscript:
        emit(state.copyWith(inputTranscript: msg.text ?? ''));
      case LiveMessageType.outputTranscript:
        emit(state.copyWith(
          status: LiveSessionStatus.aiSpeaking,
          outputTranscript: msg.text ?? '',
        ));
      case LiveMessageType.audio:
        if (msg.audioData != null) {
          await _audioPlayer.enqueueAudioChunk(msg.audioData!);
        }
      case LiveMessageType.turnComplete:
        emit(state.copyWith(status: LiveSessionStatus.listening));
      case LiveMessageType.warning:
        emit(state.copyWith(errorMessage: msg.text));
      case LiveMessageType.error:
        emit(state.copyWith(
          status: LiveSessionStatus.error,
          errorMessage: msg.text ?? 'Session error',
        ));
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

  Future<void> _onCameraToggled(
    LiveAiCameraToggled event,
    Emitter<LiveAiState> emit,
  ) async {
    if (state.isCameraActive) {
      _cameraFrameService.stopCapturing();
      emit(state.copyWith(isCameraActive: false));
    } else {
      if (!_cameraFrameService.isInitialized) {
        await _cameraFrameService.initialize();
      }
      _cameraFrameService.startCapturing(
        onFrame: _repository.sendVideoFrame,
      );
      emit(state.copyWith(isCameraActive: true));
    }
  }

  @override
  Future<void> close() async {
    await _wsSubscription?.cancel();
    await _stopAudioCapture();
    await _audioPlayer.dispose();
    await _audioRecorder.dispose();
    await _cameraFrameService.dispose();
    _repository.disconnect();
    return super.close();
  }
}
