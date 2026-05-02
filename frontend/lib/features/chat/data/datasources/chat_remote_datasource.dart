import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/chat/data/models/chat_message_model.dart';
import 'package:golden_chicken/features/chat/data/models/chat_session_model.dart';

abstract class ChatRemoteDatasource {
  Future<ChatSessionModel> createSession();

  Future<List<ChatSessionModel>> getSessions();

  Future<List<ChatMessageModel>> getMessages(String sessionId);

  Stream<String> streamMessage({
    required String sessionId,
    required String content,
    String language,
  });

  Future<void> sendFeedback({
    required String messageId,
    required int feedback,
  });
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  const ChatRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ChatSessionModel> createSession() async {
    const maxRetries = 3;
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          ApiEndpoints.chatSessions,
          data: <String, dynamic>{},
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
        return ChatSessionModel.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      } on DioException catch (e) {
        if (attempt == maxRetries) rethrow;
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          await Future<void>.delayed(Duration(seconds: attempt));
          continue;
        }
        rethrow;
      }
    }
    throw StateError('Unreachable');
  }

  @override
  Future<List<ChatSessionModel>> getSessions() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.chatSessions,
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.chatMessages(sessionId),
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<String> streamMessage({
    required String sessionId,
    required String content,
    String language = 'en',
  }) async* {
    final response = await _dio.post<ResponseBody>(
      ApiEndpoints.chatStream(sessionId),
      data: {'content': content, 'language': language},
      options: Options(
        headers: {'Accept': 'text/event-stream'},
        responseType: ResponseType.stream,
      ),
    );

    final stream = response.data!.stream;
    final sb = StringBuffer();

    await for (final chunk in stream) {
      sb.write(utf8.decode(chunk));
      final lines = sb.toString().split('\n');
      sb
        ..clear()
        ..write(lines.removeLast());

      for (final line in lines) {
        if (line.startsWith('event: done')) return;
        if (line.startsWith('data: ')) {
          try {
            final json =
                jsonDecode(line.substring(6)) as Map<String, dynamic>;
            if (json.containsKey('text')) {
              yield json['text'] as String;
            }
          } on FormatException {
            // Skip malformed SSE data
          }
        }
      }
    }
  }

  @override
  Future<void> sendFeedback({
    required String messageId,
    required int feedback,
  }) async {
    await _dio.put<void>(
      '/chat/messages/$messageId/feedback',
      data: {'feedback': feedback},
    );
  }
}
