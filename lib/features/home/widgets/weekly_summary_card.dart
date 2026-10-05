import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../data/repositories/gym_repositories.dart';
import '../../rewards/providers/loyalty_providers.dart';
import '../../rewards/rewards_screen.dart';

/// Racha semanal real — `users/{id}/visits` (la escribe el backend al
/// conceder check-in) + `weekly_goal` del socio. Tap → pantalla de
/// objetivos y recompensas.
class WeeklySummarySection extends ConsumerWidget {
  const WeeklySummarySection({super.key});

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    final goal = AppConfig.firebaseActive
        ? (member?.weeklyGoal ?? 4)
        : ref.watch(demoWeeklyGoalProvider);
    final visited = ref.watch(weekVisitedDaysProvider);

    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = now.subtract(Duration(days: todayIndex));
    final visits = visited.where((d) => d <= todayIndex).length;
    final remaining = (goal - visits).clamp(0, goal);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const RewardsScreen())),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Racha semanal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: brand.textPrimary,
                ),
              ),
              const Spacer(),
              BadgeChip(label: '$visits/$goal VISITAS', color: brand.accent),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: brand.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (visits / goal).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: brand.background,
              valueColor: AlwaysStoppedAnimation(brand.accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 15,
                color: brand.accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  remaining == 0
                      ? 'Meta semanal cumplida — buen trabajo'
                      : 'Te ${remaining == 1 ? 'falta 1 visita' : 'faltan $remaining visitas'} '
                            'para tu meta de $goal por semana',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _DayPill(
                    label: _dayLabels[i],
                    number: monday.add(Duration(days: i)).day,
                    visited: visited.contains(i),
                    isToday: i == todayIndex,
                    isFuture: i > todayIndex,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.number,
    required this.visited,
    required this.isToday,
    required this.isFuture,
  });

  final String label;
  final int number;
  final bool visited;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final highlighted = visited || isToday;
    return Opacity(
      opacity: isFuture ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        decoration: BoxDecoration(
          color: isToday ? brand.accent : brand.background,
          borderRadius: BorderRadius.circular(20),
          border: isToday ? null : Border.all(color: brand.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isToday ? brand.background : brand.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: visited
                    ? brand.accent.withValues(alpha: isToday ? 1 : 0.2)
                    : (isToday ? Colors.white : brand.surface),
                border: highlighted || visited
                    ? null
                    : Border.all(color: brand.cardBorder),
              ),
              child: Center(
                child: visited
                    ? Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: isToday ? brand.background : brand.accent,
                      )
                    : Text(
                        '$number',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isToday ? brand.background : brand.textPrimary,
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
