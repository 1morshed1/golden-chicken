import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_message.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_session.dart';
import 'package:golden_chicken/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({required ChatRemoteDatasource remoteDatasource})
      : _remote = remoteDatasource;

  final ChatRemoteDatasource _remote;

  @override
  Future<Either<Failure, ChatSession>> createSession() async {
    try {
      final session = await _remote.createSession();
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create session'));
    }
  }

  @override
  Future<Either<Failure, List<ChatSession>>> getSessions() async {
    try {
      final sessions = await _remote.getSessions();
      return Right(sessions);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load sessions'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String sessionId,
  ) async {
    try {
      final messages = await _remote.getMessages(sessionId);
      return Right(messages);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to load messages'));
    }
  }

  @override
  Stream<String> streamMessage({
    required String sessionId,
    required String content,
    String language = 'en',
  }) {
    return _remote.streamMessage(
      sessionId: sessionId,
      content: content,
      language: language,
    );
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessageWithImage({
    required String sessionId,
    required String content,
    required String imagePath,
    String language = 'en',
  }) async {
    // Will be implemented with multipart upload in a later sprint
    return const Left(ServerFailure('Image upload not yet implemented'));
  }

  @override
  Future<Either<Failure, void>> sendFeedback({
    required String messageId,
    required int feedback,
  }) async {
    try {
      await _remote.sendFeedback(
        messageId: messageId,
        feedback: feedback,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to send feedback'));
    }
  }
}
