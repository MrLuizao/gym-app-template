import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/member_avatar.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/repositories/gym_repositories.dart';
import '../../profile/profile_screen.dart';
import '../../support/providers/support_provider.dart';
import '../../support/support_chat_screen.dart';
import 'ai_coach_chat_sheet.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'BUENOS DÍAS';
    if (h < 19) return 'BUENAS TARDES';
    return 'BUENAS NOCHES';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    final streak = member?.goalStreak ?? 0;

    return Row(
      children: [
        PressableScale(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  brand.accent,
                  brand.accentDark.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: brand.accent.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipOval(
              child: MemberAvatar(
                avatarId: member?.avatarId,
                initials: member?.initials ?? 'CF',
                size: 46,
              ),
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
                  Text(
                    'Hola',
                    // _greeting(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: brand.accent,
                    ),
                  ),
                  if (streak > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: brand.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: brand.accent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 11,
                            color: brand.accent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$streak sem',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: brand.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                member?.name ?? 'Socio',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                  letterSpacing: -0.4,
                  color: brand.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (AppConfig.enableAiCoachChat) ...[
          const SizedBox(width: 8),
          const _CoachAiButton(),
        ],
        const SizedBox(width: 8),
        const _BellButton(),
      ],
    );
  }
}

class _CoachAiButton extends StatelessWidget {
  const _CoachAiButton();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      onTap: () => AiCoachChatSheet.show(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brand.surface,
          border: Border.all(
            color: brand.accent.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: brand.accent.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: brand.accent,
          ),
        ),
      ),
    );
  }
}

class _BellButton extends ConsumerWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final support = ref.watch(supportStateProvider).value;
    final unread = support?.unread ?? 0;
    return PressableScale(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SupportChatScreen()),
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brand.surface,
          border: Border.all(color: brand.cardBorder),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: brand.textPrimary,
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    color: brand.occupancyHigh,
                    border: Border.all(color: brand.surface, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
