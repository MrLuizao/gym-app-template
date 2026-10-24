import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/api_client.dart';

/// Envia feedback sobre una respuesta del chatbot.
Future<void> sendChatbotFeedback(String interactionId, bool helpful) async {
  try {
    await ApiClient.sendChatbotFeedback(interactionId, helpful);
  } catch (e) {
    // Silenciar errores de feedback - no crítico
  }
}
