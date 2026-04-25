import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_message.dart';
import 'package:golden_chicken/features/chat/domain/repositories/chat_repository.dart';

class GetChatHistory {
  const GetChatHistory(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, List<ChatMessage>>> call(String sessionId) =>
      _repository.getMessages(sessionId);
}
