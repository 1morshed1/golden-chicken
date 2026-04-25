import 'package:dartz/dartz.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_session.dart';
import 'package:golden_chicken/features/chat/domain/repositories/chat_repository.dart';

class CreateNewChat {
  const CreateNewChat(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatSession>> call() => _repository.createSession();
}
