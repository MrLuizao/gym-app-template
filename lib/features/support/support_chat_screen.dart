import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/firebase/api_client.dart';

/// Pantalla de chat de soporte — el socio puede enviar consultas y recibir
/// respuestas del staff en tiempo real.
class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String? _conversationId;
  List<_Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  StreamSubscription? _messagesSub;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _messagesSub?.cancel();
    super.dispose();
  }

  /// Busca la conversación abierta si existe — NO la crea. La conversación
  /// nace solo cuando el socio envía su primer mensaje (así abrir la
  /// pantalla o el badge de notificaciones no genera tickets vacíos).
  Future<void> _initConversation() async {
    try {
      final response = await ApiClient.get('/api/support/my-conversation');
      final id = response['id'] as String?;

      if (id != null) {
        _conversationId = id;
        _listenMessages(id);
        // Marcar mensajes del staff como leídos
        unawaited(ApiClient.get('/api/support/$id/messages'));
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el chat: $e')),
        );
      }
    }
  }

  void _listenMessages(String conversationId) {
    _messagesSub?.cancel();
    _messagesSub = FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots()
        .listen((snap) {
      setState(() {
        _messages = snap.docs.map((d) {
          final data = d.data();
          return _Message(
            id: d.id,
            sender: data['sender'] as String? ?? 'member',
            senderName: data['sender_name'] as String? ?? '',
            text: data['text'] as String? ?? '',
            createdAt: (data['created_at'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            senderType: data['sender_type'] as String?,
          );
        }).toList();
      });

      // Scroll al final
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    try {
      // Primer mensaje → intenta chatbot primero
      if (_conversationId == null) {
        final memberId = FirebaseAuth.instance.currentUser?.uid;
        if (memberId == null) return;

        // Llamar al chatbot
        final botResponse = await ApiClient.postChatbotMessage(text, memberId);

        if (botResponse['escalate_to_staff'] == true) {
          // Bot no pudo resolver → crear conversación normal
          final res = await ApiClient.post('/api/support/conversations', {});
          _conversationId = res['id'] as String?;
          if (_conversationId != null) _listenMessages(_conversationId!);
          // Re-enviar el mensaje a la conversación de staff
          await ApiClient.post(
            '/api/support/$_conversationId/messages',
            {'text': text},
          );
        } else {
          // Bot respondió → mostrar respuesta como mensaje del bot
          setState(() {
            _messages.add(_Message(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              sender: 'bot',
              senderName: 'Asistente',
              text: botResponse['response'] as String,
              createdAt: DateTime.now(),
              senderType: 'bot',
            ));
          });
        }
      } else {
        // Conversación ya existe → enviar a staff directamente
        await ApiClient.post(
          '/api/support/$_conversationId/messages',
          {'text': text},
        );
      }
    } catch (e) {
      // Staff resolvió/borró la conversación — el próximo envío crea una.
      if (e is ApiException && e.statusCode == 404) {
        _conversationId = null;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Scaffold(
      backgroundColor: brand.surface,
      appBar: AppBar(
        backgroundColor: brand.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: brand.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ayuda y soporte',
          style: TextStyle(
            color: brand.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: brand.accent),
            )
          : Column(
              children: [
                // Mensajes
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: brand.textSecondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '¿En qué podemos ayudarte?',
                                  style: TextStyle(
                                    color: brand.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Escribe tu mensaje y te responderemos lo antes posible.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: brand.textSecondary.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg.sender == 'member';
                            final isBot = msg.senderType == 'bot';

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isBot
                                      ? brand.surface.withValues(alpha: 0.5)
                                      : isMe
                                          ? brand.accent
                                          : brand.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isMe
                                      ? null
                                      : Border.all(
                                          color: isBot
                                              ? brand.accent.withValues(alpha: 0.3)
                                              : brand.cardBorder,
                                        ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isBot)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.smart_toy_outlined,
                                            size: 12,
                                            color: brand.accent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Asistente',
                                            style: TextStyle(
                                              color: brand.accent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : brand.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(msg.createdAt),
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white70
                                            : brand.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Input
                Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    12 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: brand.surface,
                    border: Border(
                      top: BorderSide(color: brand.cardBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: brand.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            hintStyle: TextStyle(color: brand.textSecondary),
                            filled: true,
                            fillColor: brand.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sending ? null : _sendMessage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: brand.accent,
                            shape: BoxShape.circle,
                          ),
                          child: _sending
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Message {
  final String id;
  final String sender;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final String? senderType; // 'bot' | 'staff' | 'member'

  _Message({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.senderType,
  });
}
