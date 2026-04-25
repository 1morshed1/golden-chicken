import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.lastMessageAt,
    this.messageCount = 0,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final int messageCount;

  @override
  List<Object?> get props => [id, title, createdAt, lastMessageAt, messageCount];
}
