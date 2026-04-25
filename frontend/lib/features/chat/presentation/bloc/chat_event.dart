import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatSessionStarted extends ChatEvent {
  const ChatSessionStarted(this.sessionId);
  final String? sessionId;

  @override
  List<Object?> get props => [sessionId];
}

final class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({required this.content, this.language = 'en'});
  final String content;
  final String language;

  @override
  List<Object?> get props => [content, language];
}

final class ChatStreamChunkReceived extends ChatEvent {
  const ChatStreamChunkReceived(this.chunk);
  final String chunk;

  @override
  List<Object?> get props => [chunk];
}

final class ChatStreamCompleted extends ChatEvent {
  const ChatStreamCompleted();
}

final class ChatStreamErrorOccurred extends ChatEvent {
  const ChatStreamErrorOccurred(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
