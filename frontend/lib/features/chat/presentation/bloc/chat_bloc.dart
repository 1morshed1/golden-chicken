import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/features/chat/domain/entities/chat_message.dart';
import 'package:golden_chicken/features/chat/domain/usecases/create_new_chat.dart';
import 'package:golden_chicken/features/chat/domain/usecases/get_chat_history.dart';
import 'package:golden_chicken/features/chat/domain/usecases/send_message.dart';
import 'package:golden_chicken/features/chat/presentation/bloc/chat_event.dart';
import 'package:golden_chicken/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required CreateNewChat createNewChat,
    required GetChatHistory getChatHistory,
    required SendMessage sendMessage,
  })  : _createNewChat = createNewChat,
        _getChatHistory = getChatHistory,
        _sendMessage = sendMessage,
        super(const ChatInitial()) {
    on<ChatSessionStarted>(_onSessionStarted);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatStreamChunkReceived>(_onStreamChunk);
    on<ChatStreamCompleted>(_onStreamCompleted);
    on<ChatStreamErrorOccurred>(_onStreamError);
  }

  final CreateNewChat _createNewChat;
  final GetChatHistory _getChatHistory;
  final SendMessage _sendMessage;
  StreamSubscription<String>? _streamSub;

  Future<void> _onSessionStarted(
    ChatSessionStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    String sessionId;
    List<ChatMessage> messages;

    if (event.sessionId != null) {
      sessionId = event.sessionId!;
      final result = await _getChatHistory(sessionId);
      messages = result.fold((_) => [], (msgs) => msgs);
    } else {
      final result = await _createNewChat();
      final session = result.fold(
        (failure) {
          emit(ChatError(failure.message));
          return null;
        },
        (s) => s,
      );
      if (session == null) return;
      sessionId = session.id;
      messages = [];
    }

    emit(ChatLoaded(messages: messages, sessionId: sessionId));
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;

    final userMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: current.sessionId,
      role: MessageRole.user,
      content: event.content,
      createdAt: DateTime.now(),
    );

    emit(
      current.copyWith(
        messages: [...current.messages, userMessage],
        isSending: true,
        isStreaming: true,
        streamingContent: '',
      ),
    );

    await _streamSub?.cancel();
    _streamSub = _sendMessage(
      sessionId: current.sessionId,
      content: event.content,
      language: event.language,
    ).listen(
      (chunk) => add(ChatStreamChunkReceived(chunk)),
      onDone: () => add(const ChatStreamCompleted()),
      onError: (Object error) =>
          add(ChatStreamErrorOccurred(error.toString())),
    );
  }

  void _onStreamChunk(
    ChatStreamChunkReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;

    emit(
      current.copyWith(
        streamingContent: current.streamingContent + event.chunk,
      ),
    );
  }

  void _onStreamCompleted(
    ChatStreamCompleted event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;

    final aiMessage = ChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: current.sessionId,
      role: MessageRole.ai,
      content: current.streamingContent,
      createdAt: DateTime.now(),
    );

    emit(
      current.copyWith(
        messages: [...current.messages, aiMessage],
        isSending: false,
        isStreaming: false,
        streamingContent: '',
      ),
    );
  }

  void _onStreamError(
    ChatStreamErrorOccurred event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;

    emit(
      current.copyWith(
        isSending: false,
        isStreaming: false,
        streamingContent: '',
      ),
    );
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
