import 'dart:convert';

import 'package:golden_chicken/features/live_ai/data/datasources/live_ai_websocket_datasource.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';
import 'package:golden_chicken/features/live_ai/domain/repositories/live_ai_repository.dart';

class LiveAiRepositoryImpl implements LiveAiRepository {
  LiveAiRepositoryImpl({required LiveAiWebSocketDatasource datasource})
      : _datasource = datasource;

  final LiveAiWebSocketDatasource _datasource;

  @override
  Stream<LiveAiMessage> connect(String token) => _datasource.connect(token);

  @override
  void sendAudio(List<int> data) {
    _datasource.send({
      'type': 'audio',
      'data': base64Encode(data),
    });
  }

  @override
  void sendVideoFrame(String base64Frame) {
    _datasource.send({
      'type': 'video_frame',
      'data': base64Frame,
    });
  }

  @override
  void sendText(String text) {
    _datasource.send({
      'type': 'text',
      'text': text,
    });
  }

  @override
  void endSession() {
    _datasource.send({'type': 'end_session'});
  }

  @override
  void disconnect() => _datasource.disconnect();
}
