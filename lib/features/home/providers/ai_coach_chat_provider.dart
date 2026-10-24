import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/api_client.dart';

class AiCoachChatMessage {
  const AiCoachChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  Map<String, String> toApiFormat() {
    return {
      'role': isUser ? 'user' : 'model',
      'text': text,
    };
  }
}

class AiCoachChatState {
  const AiCoachChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final List<AiCoachChatMessage> messages;
  final bool isSending;
  final String? error;

  AiCoachChatState copyWith({
    List<AiCoachChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return AiCoachChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class AiCoachChatNotifier extends Notifier<AiCoachChatState> {
  @override
  AiCoachChatState build() => const AiCoachChatState();

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMsg = AiCoachChatMessage(
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final historyForApi = state.messages
        .take(8)
        .map((m) => m.toApiFormat())
        .toList();

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      error: null,
    );

    try {
      final res = await ApiClient.post('/api/members/ai-coach/chat', {
        'message': trimmed,
        'history': historyForApi,
      });

      final replyText = (res['reply'] as String?)?.trim() ??
          '¡Gran pregunta! Recuerda mantener siempre una técnica sólida y consultar al staff de piso ante cualquier duda.';

      final coachMsg = AiCoachChatMessage(
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, coachMsg],
        isSending: false,
      );
    } catch (e) {
      final fallbackMsg = AiCoachChatMessage(
        text:
            '⚠️ No pude conectar con el Coach en este momento. Por favor revisa tu conexión o intenta nuevamente.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackMsg],
        isSending: false,
        error: '$e',
      );
    }
  }

  void clearChat() {
    state = const AiCoachChatState();
  }
}

final aiCoachChatProvider =
    NotifierProvider<AiCoachChatNotifier, AiCoachChatState>(
  AiCoachChatNotifier.new,
);
