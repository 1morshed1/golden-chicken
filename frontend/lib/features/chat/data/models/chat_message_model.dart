import 'package:golden_chicken/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sessionId,
    required super.role,
    required super.content,
    required super.createdAt,
    super.imageUrl,
    super.feedback,
    super.isStreaming,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      role: (json['role'] as String) == 'user' ? MessageRole.user : MessageRole.ai,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
      feedback: json['feedback'] as int?,
    );
  }
}
