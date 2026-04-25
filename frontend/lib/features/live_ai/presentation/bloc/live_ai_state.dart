import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';

class LiveAiState extends Equatable {
  const LiveAiState({
    this.status = LiveSessionStatus.idle,
    this.inputTranscript = '',
    this.outputTranscript = '',
    this.errorMessage,
  });

  final LiveSessionStatus status;
  final String inputTranscript;
  final String outputTranscript;
  final String? errorMessage;

  LiveAiState copyWith({
    LiveSessionStatus? status,
    String? inputTranscript,
    String? outputTranscript,
    String? errorMessage,
  }) {
    return LiveAiState(
      status: status ?? this.status,
      inputTranscript: inputTranscript ?? this.inputTranscript,
      outputTranscript: outputTranscript ?? this.outputTranscript,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        inputTranscript,
        outputTranscript,
        errorMessage,
      ];
}
