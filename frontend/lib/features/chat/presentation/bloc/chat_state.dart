import 'package:equatable/equatable.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_message.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.messages,
    required this.sessionId,
    this.isSending = false,
    this.isStreaming = false,
    this.streamingContent = '',
  });

  final List<ChatMessage> messages;
  final String sessionId;
  final bool isSending;
  final bool isStreaming;
  final String streamingContent;

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    bool? isStreaming,
    String? streamingContent,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      sessionId: sessionId,
      isSending: isSending ?? this.isSending,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingContent: streamingContent ?? this.streamingContent,
    );
  }

  @override
  List<Object?> get props =>
      [messages, sessionId, isSending, isStreaming, streamingContent];
}

final class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
