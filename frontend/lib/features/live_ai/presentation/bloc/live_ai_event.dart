import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';

sealed class LiveAiEvent extends Equatable {
  const LiveAiEvent();

  @override
  List<Object?> get props => [];
}

final class LiveAiStartRequested extends LiveAiEvent {
  const LiveAiStartRequested();
}

final class LiveAiStopRequested extends LiveAiEvent {
  const LiveAiStopRequested();
}

final class LiveAiMessageReceived extends LiveAiEvent {
  const LiveAiMessageReceived(this.message);

  final LiveAiMessage message;

  @override
  List<Object?> get props => [message];
}

final class LiveAiErrorOccurred extends LiveAiEvent {
  const LiveAiErrorOccurred(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

final class LiveAiTextSent extends LiveAiEvent {
  const LiveAiTextSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
