import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/config/app_config.dart';
import '../../core/firebase/auth_provider.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/member_avatar.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/gym_repositories.dart';
import '../legal/legal_screen.dart';
import '../payments/checkout_screen.dart';
import '../payments/providers/membership_provider.dart';
import '../support/support_chat_screen.dart';
import 'settings_screen.dart';
import 'widgets/avatar_picker_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    final membership = ref.watch(membershipProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            right: -40,
            height: 280,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: 0.9,
                    colors: [
                      brand.accent.withValues(alpha: 0.16),
                      brand.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Center(
                child: Column(
                  children: [
                    PressableScale(
                      onTap: member == null
                          ? null
                          : () => AvatarPickerSheet.show(context, member),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: brand.accent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: brand.accent.withValues(alpha: 0.24),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          MemberAvatar(
                            avatarId: member?.avatarId,
                            initials: member?.initials ?? 'CF',
                            size: 92,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: brand.accent,
                                border: Border.all(
                                  color: brand.background,
                                  width: 2.5,
                                ),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: brand.readableOn(brand.accent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              if (member != null && member.avatarId == null) ...[
                const SizedBox(height: 8),
                Text(
                  'Toca para elegir tu avatar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: brand.accent,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                member?.name ?? 'Socio',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'SOCIO Nº ${member?.memberNumber ?? '—'}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(letterSpacing: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BadgeChip(
                    label: planNameFor(member?.planId ?? ''),
                    color: brand.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Text('Mi membresía', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.card_membership_rounded,
                label: 'Plan',
                value: planNameFor(membership.planId),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _InfoRow(
                icon: Icons.event_available_rounded,
                label: 'Vence',
                value: _formatDate(membership.expiresAt),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _InfoRow(
                icon: Icons.verified_rounded,
                label: 'Estado',
                value: membership.isActive ? 'ACTIVA' : 'VENCIDA',
                valueColor: membership.isActive
                    ? brand.occupancyLow
                    : brand.occupancyHigh,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'RENOVAR MEMBRESÍA',
          icon: Icons.credit_card_rounded,
          onTap: () => Navigator.of(
            context,
          ).pushNamed(MembershipCheckoutScreen.routeName),
        ),
        const SizedBox(height: 24),
        Text('Cuenta', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Ayuda y soporte',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SupportChatScreen(),
                  ),
                ),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _ActionRow(
                icon: Icons.notifications_active_rounded,
                label: 'Notificaciones',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _ActionRow(
                icon: Icons.gavel_rounded,
                label: 'Legal',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalScreen()),
                ),
              ),
              if (AppConfig.firebaseActive) ...[
                Divider(height: 1, indent: 56, color: brand.cardBorder),
                _ActionRow(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                  labelColor: brand.occupancyHigh,
                  onTap: () => ref.read(authControllerProvider).signOut(),
                ),
              ],
            ],
          ),
        ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: brand.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Icon(icon, size: 16, color: brand.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: brand.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: valueColor ?? brand.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              AppHaptics.light();
              onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: brand.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brand.cardBorder),
              ),
              child: Icon(icon, size: 16, color: brand.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: labelColor ?? brand.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: brand.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
