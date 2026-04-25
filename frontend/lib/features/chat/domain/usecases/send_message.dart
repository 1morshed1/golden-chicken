import 'package:golden_chicken/features/chat/domain/repositories/chat_repository.dart';

class SendMessage {
  const SendMessage(this._repository);

  final ChatRepository _repository;

  Stream<String> call({
    required String sessionId,
    required String content,
    String language = 'en',
  }) {
    return _repository.streamMessage(
      sessionId: sessionId,
      content: content,
      language: language,
    );
  }
}
