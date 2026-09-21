import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../data/models/member.dart';

class VipMemberCard extends StatelessWidget {
  const VipMemberCard({super.key, this.member});

  final Member? member;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final active = member?.isActive ?? false;
    final statusColor = active ? brand.occupancyLow : brand.occupancyHigh;
    return Container(
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.4),
        gradient: LinearGradient(
          colors: [
            brand.accent,
            brand.accent.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 84,
                  height: 108,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: brand.cardBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: member?.photoUrl != null
                        ? Image.network(
                            member!.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _PhotoFallback(
                                initials: member!.initials),
                          )
                        : _PhotoFallback(initials: member?.initials ?? 'CF'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BadgeChip(
                        label: active ? 'MEMBRESÍA ACTIVA' : 'MEMBRESÍA VENCIDA',
                        color: statusColor,
                        icon: active
                            ? Icons.verified_rounded
                            : Icons.error_rounded,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        member?.name ?? 'Socio Capital',
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'SOCIO Nº ${member?.memberNumber ?? '—'}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(letterSpacing: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoPill(
                  icon: Icons.card_membership_rounded,
                  label: member?.plan ?? 'Plan Black',
                ),
                const SizedBox(width: 10),
                if (member?.membershipUntil != null)
                  Text(
                    'Vence ${_formatDate(member!.membershipUntil!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const Spacer(),
                Icon(
                  Icons.fitness_center_rounded,
                  size: 18,
                  color: brand.accent.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return ColoredBox(
      color: brand.background,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: brand.accent,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: brand.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: brand.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
