import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';

abstract class LiveAiRepository {
  Stream<LiveAiMessage> connect(String token);
  void sendAudio(List<int> data);
  void sendVideoFrame(String base64Frame);
  void sendText(String text);
  void endSession();
  void disconnect();
}
