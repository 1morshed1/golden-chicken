import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_message.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_session.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatSession>> createSession();

  Future<Either<Failure, List<ChatSession>>> getSessions();

  Future<Either<Failure, List<ChatMessage>>> getMessages(String sessionId);

  Stream<String> streamMessage({
    required String sessionId,
    required String content,
    String language,
  });

  Future<Either<Failure, ChatMessage>> sendMessageWithImage({
    required String sessionId,
    required String content,
    required String imagePath,
    String language,
  });

  Future<Either<Failure, void>> sendFeedback({
    required String messageId,
    required int feedback,
  });
}
