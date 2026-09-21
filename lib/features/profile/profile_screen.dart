import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/gym_repositories.dart';
import '../payments/checkout_screen.dart';
import '../payments/providers/membership_provider.dart';

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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: brand.accent, width: 2),
                ),
                child: ClipOval(
                  child: member?.photoUrl != null
                      ? Image.network(
                          member!.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _InitialsFallback(
                            initials: member.initials,
                          ),
                        )
                      : _InitialsFallback(initials: member?.initials ?? 'CF'),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                member?.name ?? 'Socio',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'SOCIO Nº ${member?.memberNumber ?? '—'}',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(letterSpacing: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BadgeChip(
                    label: member?.plan ?? 'Plan Classic',
                    color: brand.accent,
                  ),
                  const SizedBox(width: 8),
                  BadgeChip(
                    label: member?.level ?? 'CLASSIC',
                    color: brand.textSecondary,
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
                value: membership.plan,
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
          onTap: () => Navigator.of(context)
              .pushNamed(MembershipCheckoutScreen.routeName),
        ),
        const SizedBox(height: 24),
        Text('Cuenta', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.receipt_long_rounded,
                label: 'Historial de visitas',
                onTap: () => _soon(context),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _ActionRow(
                icon: Icons.payments_rounded,
                label: 'Métodos de pago',
                onTap: () => _soon(context),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _ActionRow(
                icon: Icons.notifications_rounded,
                label: 'Notificaciones',
                onTap: () => _soon(context),
              ),
              Divider(height: 1, indent: 56, color: brand.cardBorder),
              _ActionRow(
                icon: Icons.help_outline_rounded,
                label: 'Ayuda y soporte',
                onTap: () => _soon(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        content: const Text(
          'Disponible próximamente',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return InkWell(
      onTap: onTap,
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
                  color: brand.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: brand.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return ColoredBox(
      color: brand.surface,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: brand.accent,
          ),
        ),
      ),
    );
  }
}
