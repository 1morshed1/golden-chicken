import 'package:equatable/equatable.dart';

enum LiveSessionStatus {
  idle,
  connecting,
  listening,
  aiSpeaking,
  error,
}

enum LiveMessageType {
  sessionStarted,
  audio,
  inputTranscript,
  outputTranscript,
  turnComplete,
  warning,
  error,
}

class LiveAiMessage extends Equatable {
  const LiveAiMessage({
    required this.type,
    this.text,
    this.audioData,
  });

  final LiveMessageType type;
  final String? text;
  final List<int>? audioData;

  @override
  List<Object?> get props => [type, text];
}
