import 'package:equatable/equatable.dart';

enum MessageRole { user, ai }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.feedback,
    this.isStreaming = false,
  });

  final String id;
  final String sessionId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;
  final int? feedback;
  final bool isStreaming;

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    int? feedback,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content ?? this.content,
      createdAt: createdAt,
      imageUrl: imageUrl,
      feedback: feedback ?? this.feedback,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        role,
        content,
        createdAt,
        imageUrl,
        feedback,
        isStreaming,
      ];
}
