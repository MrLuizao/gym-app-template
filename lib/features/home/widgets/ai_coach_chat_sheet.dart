import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../providers/ai_coach_chat_provider.dart';
import '../providers/ai_coach_provider.dart';

/// Hoja interactiva del "Coach de Bolsillo" — Asistente de Entrenamiento & Nutrición IA
class AiCoachChatSheet extends ConsumerStatefulWidget {
  const AiCoachChatSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiCoachChatSheet(),
    );
  }

  @override
  ConsumerState<AiCoachChatSheet> createState() => _AiCoachChatSheetState();
}

class _AiCoachChatSheetState extends ConsumerState<AiCoachChatSheet> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  static const _quickPrompts = [
    '🔥 ¿Cómo caliento para pierna hoy?',
    '🥗 ¿Qué comer 30 min antes de entrenar?',
    '🩹 Siento molestia en espalda baja en peso muerto',
    '⏱️ ¿Cuánto descansar entre series pesadas?',
    '🏋️‍♂️ Rutina express de 40 min para hoy',
    '💧 ¿Cuánta agua tomar durante mi entreno?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    ref.read(aiCoachChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final chatState = ref.watch(aiCoachChatProvider);
    final coachAsync = ref.watch(aiCoachProvider);
    final branchName = coachAsync.value?.branchName ?? 'tu gimnasio';

    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final sheetHeight = mediaQuery.size.height * 0.88;

    // Escuchar cambios de mensajes para scrollear automáticamente
    ref.listen<AiCoachChatState>(aiCoachChatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.isSending != next.isSending) {
        _scrollToBottom();
      }
    });

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: brand.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: brand.accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
          left: BorderSide(color: brand.cardBorder),
          right: BorderSide(color: brand.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barra de agarre superior
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: brand.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header con avatar y estado del Coach
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brand.accent,
                        brand.accent.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: brand.accent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Coach de Bolsillo',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: brand.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: brand.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: brand.accent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'IA',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: brand.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6.5,
                            height: 6.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: brand.occupancyLow,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'En línea • $branchName',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: brand.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: brand.textSecondary,
                  ),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Chips de preguntas rápidas preconfiguradas
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: brand.textPrimary,
                    ),
                  ),
                  backgroundColor: brand.surface,
                  side: BorderSide(
                    color: brand.cardBorder.withValues(alpha: 0.9),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: chatState.isSending
                      ? null
                      : () => _sendMessage(prompt),
                );
              },
            ),
          ),

          // Área de conversación
          Expanded(
            child: chatState.messages.isEmpty
                ? _WelcomeView(
                    branchName: branchName,
                    onPromptTap: (p) => _sendMessage(p),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: chatState.messages.length +
                        (chatState.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return _TypingBubble(brand: brand);
                      }
                      final msg = chatState.messages[index];
                      return _MessageBubble(
                        message: msg,
                        brand: brand,
                      );
                    },
                  ),
          ),

          // Campo de entrada de texto
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              12 + bottomInset,
            ),
            decoration: BoxDecoration(
              color: brand.surface,
              border: Border(
                top: BorderSide(color: brand.cardBorder),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: brand.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: brand.cardBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: 4,
                      minLines: 1,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: brand.textPrimary,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Pregúntale a tu Coach...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: brand.textSecondary.withValues(alpha: 0.8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: chatState.isSending ? null : () => _sendMessage(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          brand.accent,
                          brand.accent.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: brand.accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: chatState.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
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

/// Mensaje de bienvenida inicial cuando aún no hay historial
class _WelcomeView extends StatelessWidget {
  const _WelcomeView({
    required this.branchName,
    required this.onPromptTap,
  });

  final String branchName;
  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: brand.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: brand.accent.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.sports_gymnastics_rounded,
              size: 32,
              color: brand.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Hola, Atleta!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Soy tu Coach de Bolsillo en $branchName. Estoy listo para guiarte en tu entrenamiento, calentar seguro, corregir técnica o resolver qué comer hoy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: brand.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brand.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      size: 16,
                      color: brand.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TEMAS EN LOS QUE PUEDO AYUDARTE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: brand.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FeatureBullet(
                  icon: Icons.fitness_center_rounded,
                  title: 'Técnica de ejercicios',
                  description: 'Cues posturales para sentadilla, peso muerto y banca.',
                  brand: brand,
                ),
                const SizedBox(height: 10),
                _FeatureBullet(
                  icon: Icons.timer_outlined,
                  title: 'Calentamiento y tiempos',
                  description: 'Movilidad articular específica y pausas entre series.',
                  brand: brand,
                ),
                const SizedBox(height: 10),
                _FeatureBullet(
                  icon: Icons.restaurant_rounded,
                  title: 'Nutrición pre y post entreno',
                  description: 'Qué ingerir para rendir más y recuperarte rápido.',
                  brand: brand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.description,
    required this.brand,
  });

  final IconData icon;
  final String title;
  final String description;
  final BrandConfig brand;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: brand.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: brand.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: brand.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.5,
                  color: brand.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Burbuja individual de mensaje
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.brand,
  });

  final AiCoachChatMessage message;
  final BrandConfig brand;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: brand.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: brand.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: brand.accent,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? brand.accent.withValues(alpha: 0.22)
                    : brand.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? brand.accent.withValues(alpha: 0.5)
                      : brand.cardBorder,
                ),
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: 13,
                  color: brand.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador animado de "escribiendo..."
class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.brand});

  final BrandConfig brand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: brand.accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: brand.accent.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: brand.accent,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: brand.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(brand.accent),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'El Coach está respondiendo...',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: brand.textSecondary,
                    fontWeight: FontWeight.w600,
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
