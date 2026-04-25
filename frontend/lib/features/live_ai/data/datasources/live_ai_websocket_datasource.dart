import 'dart:convert';

import 'package:golden_chicken/core/constants/api_endpoints.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveAiWebSocketDatasource {
  WebSocketChannel? _channel;

  Stream<LiveAiMessage> connect(String token) {
    final uri = Uri.parse(
      '${ApiEndpoints.wsBaseUrl}${ApiEndpoints.liveAiStream(token)}',
    );
    _channel = WebSocketChannel.connect(uri);
    return _channel!.stream.map(_parseMessage);
  }

  LiveAiMessage _parseMessage(dynamic raw) {
    if (raw is! String) {
      return const LiveAiMessage(type: LiveMessageType.error, text: 'Unknown');
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final type = json['type'] as String?;
    return switch (type) {
      'session_started' =>
        const LiveAiMessage(type: LiveMessageType.sessionStarted),
      'audio' => LiveAiMessage(
          type: LiveMessageType.audio,
          audioData: (json['data'] as String?)?.codeUnits,
        ),
      'input_transcript' => LiveAiMessage(
          type: LiveMessageType.inputTranscript,
          text: json['text'] as String?,
        ),
      'output_transcript' => LiveAiMessage(
          type: LiveMessageType.outputTranscript,
          text: json['text'] as String?,
        ),
      'turn_complete' =>
        const LiveAiMessage(type: LiveMessageType.turnComplete),
      'warning' => LiveAiMessage(
          type: LiveMessageType.warning,
          text: json['message'] as String?,
        ),
      'error' => LiveAiMessage(
          type: LiveMessageType.error,
          text: json['message'] as String?,
        ),
      _ => LiveAiMessage(
          type: LiveMessageType.error,
          text: 'Unknown message type: $type',
        ),
    };
  }

  void send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
