import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/capacity_bar.dart';
import '../../../core/widgets/capacity_ring.dart';
import '../providers/branch_providers.dart';

class OverallOccupancyBanner extends ConsumerWidget {
  const OverallOccupancyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final overall = ref.watch(overallOccupancyProvider);
    final ratio = overall?.ratio ?? 0;
    return Container(
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.4),
        gradient: LinearGradient(
          colors: [
            brand.accent.withValues(alpha: 0.9),
            brand.accentDark.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'AFORO GENERAL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.8,
                        color: brand.textSecondary,
                      ),
                ),
                const Spacer(),
                BadgeChip(
                  label: 'EN VIVO',
                  color: brand.occupancyLow,
                  icon: Icons.fiber_manual_record,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${(ratio * 100).round()}',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -1.5,
                    color: brand.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: brand.accent,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'OCUPACIÓN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CapacityRing(value: ratio, size: 76, strokeWidth: 7),
              ],
            ),
            const SizedBox(height: 14),
            CapacityBar(value: ratio, height: 8),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.groups_rounded,
                    size: 15, color: brand.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${overall?.current ?? 0} socios entrenando ahora',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                _LegendDot(color: brand.occupancyLow, label: 'Bajo'),
                const SizedBox(width: 10),
                _LegendDot(color: brand.occupancyMedium, label: 'Medio'),
                const SizedBox(width: 10),
                _LegendDot(color: brand.occupancyHigh, label: 'Alto'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: brand.textSecondary,
          ),
        ),
      ],
    );
  }
}
