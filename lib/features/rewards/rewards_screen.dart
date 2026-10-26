import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/ambient_glow.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/models/reward.dart';
import '../../data/repositories/gym_repositories.dart';
import 'providers/loyalty_providers.dart';

/// Objetivos de asistencia + recompensas — el socio define su meta
/// semanal, ve su progreso real (check-ins) y canjea los puntos que
/// gana al cumplirla.
///
/// `embedded`: true cuando vive como tab del MainShell (header propio,
/// padding para el bottom nav); false cuando se empuja como ruta
/// (envuelta en Scaffold con AppBar + back).
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key, this.embedded = true});

  final bool embedded;

  static const dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(memberProvider).value;
    final goal = AppConfig.firebaseActive
        ? (member?.weeklyGoal ?? 4)
        : ref.watch(demoWeeklyGoalProvider);
    final points = AppConfig.firebaseActive ? (member?.points ?? 0) : 60;
    final visited = ref.watch(weekVisitedDaysProvider);
    final awarded = AppConfig.firebaseActive
        ? member?.goalAwardedWeek == dateKey(weekMonday())
        : false;

    final brand = context.brand;
    final body = Stack(
      children: [
        const AmbientTopGlow(),
        ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            embedded ? 16 : 8,
            20,
            embedded ? 130 : 40,
          ),
          children: [
        if (embedded) ...[
          Text('Premios', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Cumple tu meta semanal y canjea recompensas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
        ],
        _PointsCard(points: points),
        const SizedBox(height: 16),
        _GoalCard(goal: goal, visited: visited, awarded: awarded),
        const SizedBox(height: 16),
        _StreakBonusesCard(streak: member?.goalStreak ?? 0, goal: goal),
        const SizedBox(height: 24),
        Text('Recompensas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _RewardsList(),
        const SizedBox(height: 24),
        Text('Mis códigos', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const _RedemptionsList(),
        const SizedBox(height: 24),
        Text(
          'Historial de puntos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const _PointsHistoryList(),
      ],
    ),
      ],
    );
    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Objetivos y recompensas')),
      body: body,
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BrandConfig.logoIndigo.withValues(alpha: 0.35),
                  BrandConfig.logoViolet.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                colors: BrandConfig.logoGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: points.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) => Text(
                    '${val.round()}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: brand.textPrimary,
                    ),
                  ),
                ),
                Text(
                  'PUNTOS DISPONIBLES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: brand.textSecondary,
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

class _GoalCard extends ConsumerWidget {
  const _GoalCard({
    required this.goal,
    required this.visited,
    required this.awarded,
  });

  final int goal;
  final Set<int> visited;
  final bool awarded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = weekMonday();
    final visits = visited.length;
    final remaining = (goal - visits).clamp(0, goal);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Mi meta semanal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: brand.textPrimary,
                ),
              ),
              const Spacer(),
              BadgeChip(
                label: awarded ? 'PREMIO GANADO' : '$visits/$goal VISITAS',
                color: awarded ? brand.occupancyLow : brand.accent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: (visits / goal).clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) => ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 7,
                backgroundColor: brand.background,
                valueColor: AlwaysStoppedAnimation(
                  awarded ? brand.occupancyLow : brand.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                awarded
                    ? Icons.emoji_events_rounded
                    : Icons.local_fire_department_rounded,
                size: 15,
                color: awarded ? brand.occupancyLow : brand.accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  awarded
                      ? 'Meta cumplida — +${getGoalBonusPoints(goal)} pts ganados esta semana'
                      : remaining == 0
                      ? 'Meta cumplida — buen trabajo'
                      : 'Te ${remaining == 1 ? 'falta 1 visita' : 'faltan $remaining visitas'} '
                            'para ganar ${getGoalBonusPoints(goal)} pts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _DayPill(
                    label: RewardsScreen.dayLabels[i],
                    number: monday.add(Duration(days: i)).day,
                    visited: visited.contains(i),
                    isToday: i == todayIndex,
                    isFuture: i > todayIndex,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'AJUSTA TU META (VISITAS POR SEMANA)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var n = 2; n <= 6; n++) ...[
                if (n > 2) const SizedBox(width: 8),
                Expanded(
                  child: PressableScale(
                    enableHaptic: false,
                    onTap: () {
                      if (n != goal) {
                        AppHaptics.selection();
                        setWeeklyGoal(ref, n);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: n == goal ? brand.accent : brand.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: n == goal ? brand.accent : brand.cardBorder,
                        ),
                        boxShadow: n == goal
                            ? [
                                BoxShadow(
                                  color: brand.accent.withValues(alpha: 0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$n',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: n == goal
                                ? brand.readableOn(brand.accent)
                                : brand.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: brand.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: BrandConfig.logoViolet.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    size: 16,
                    color: BrandConfig.logoViolet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recompensa: +${getGoalBonusPoints(goal)} pts semanales',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: brand.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tus bonos por racha escalan proporcionalmente a tu meta semanal.',
                        style: TextStyle(
                          fontSize: 10,
                          color: brand.textSecondary,
                        ),
                      ),
                    ],
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

class _StreakBonusesCard extends StatelessWidget {
  const _StreakBonusesCard({required this.streak, required this.goal});

  final int streak;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    const milestones = [2, 4, 8, 12];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: BrandConfig.logoPink,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bonos por Racha Continua',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: brand.textPrimary,
                  ),
                ),
              ),
              if (streak > 0)
                BadgeChip(
                  label: '$streak SEMANAS',
                  color: BrandConfig.logoPink,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Los premios crecen según tu meta de $goal visitas semanales:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < milestones.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _MilestonePill(
                    weeks: milestones[i],
                    points: getStreakBonus(milestones[i], goal),
                    reached: streak >= milestones[i],
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

class _MilestonePill extends StatelessWidget {
  const _MilestonePill({
    required this.weeks,
    required this.points,
    required this.reached,
  });

  final int weeks;
  final int points;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: reached
            ? BrandConfig.logoViolet.withValues(alpha: 0.16)
            : brand.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reached
              ? BrandConfig.logoViolet.withValues(alpha: 0.6)
              : brand.cardBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                reached
                    ? Icons.check_circle_rounded
                    : Icons.local_fire_department_rounded,
                size: 13,
                color: reached
                    ? BrandConfig.logoViolet
                    : brand.textSecondary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 3),
              Text(
                '${weeks}s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: reached ? BrandConfig.logoViolet : brand.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '+$points',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: reached ? brand.textPrimary : brand.textSecondary,
            ),
          ),
          Text(
            'pts',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: brand.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardsList extends ConsumerWidget {
  const _RewardsList();

  static const _icons = <String, IconData>{
    'cup': Icons.emoji_food_beverage_rounded,
    'users': Icons.group_rounded,
    'dumbbell': Icons.fitness_center_rounded,
    'calendar': Icons.calendar_month_rounded,
    'shirt': Icons.checkroom_rounded,
    'gift': Icons.card_giftcard_rounded,
  };

  Future<void> _redeem(
    BuildContext context,
    WidgetRef ref,
    Reward reward,
    int points,
  ) async {
    if (!AppConfig.firebaseActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponible con tu cuenta de socio')),
      );
      return;
    }
    if (points < reward.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Te faltan ${reward.pointsCost - points} pts para esta recompensa',
          ),
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reward.name),
        content: Text(
          '¿Canjear ${reward.pointsCost} puntos? Te quedará un código '
          'para mostrar en recepción.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      AppHaptics.medium();
      final code = await redeemReward(reward.id);
      AppHaptics.heavy();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Recompensa canjeada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Muestra este código en recepción:',
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                code,
                style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo completar el canje')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final rewardsAsync = ref.watch(rewardsProvider);
    final points = AppConfig.firebaseActive
        ? (ref.watch(memberProvider).value?.points ?? 0)
        : 60;

    return rewardsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => AppCard(
        child: Text(
          'No se pudieron cargar las recompensas',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (rewards) => Column(
        children: [
          for (final reward in rewards)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: brand.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _icons[reward.icon] ?? Icons.card_giftcard_rounded,
                        size: 22,
                        color: brand.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: brand.textPrimary,
                            ),
                          ),
                          Text(
                            reward.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${reward.pointsCost} PTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: brand.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: points >= reward.pointsCost
                          ? () => _redeem(context, ref, reward, points)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: brand.accent,
                        foregroundColor: brand.background,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: const Size(0, 36),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      child: const Text('CANJEAR'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RedemptionsList extends ConsumerWidget {
  const _RedemptionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final redemptionsAsync = ref.watch(redemptionsProvider);

    return redemptionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (redemptions) {
        if (redemptions.isEmpty) {
          return AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 20,
                  color: brand.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Aún no tienes códigos — canjea una recompensa y '
                    'aparecerá aquí.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            for (final r in redemptions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.rewardName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: brand.textPrimary,
                              ),
                            ),
                            Text(
                              r.isActive
                                  ? 'Vigente'
                                  : r.status == 'used'
                                  ? 'Usado'
                                  : 'Expirado',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      PressableScale(
                        onTap: r.isActive
                            ? () {
                                AppHaptics.selection();
                                Clipboard.setData(ClipboardData(text: r.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Código ${r.code} copiado'),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: r.isActive
                                ? brand.accent.withValues(alpha: 0.14)
                                : brand.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: r.isActive
                                  ? brand.accent.withValues(alpha: 0.4)
                                  : brand.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                r.code,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: r.isActive
                                      ? brand.accent
                                      : brand.textSecondary,
                                ),
                              ),
                              if (r.isActive) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: brand.accent,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isToday ? brand.accent : brand.background,
          borderRadius: BorderRadius.circular(18),
          border: isToday ? null : Border.all(color: brand.cardBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isToday ? brand.background : brand.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 22,
              height: 22,
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
                        size: 13,
                        color: isToday ? brand.background : brand.accent,
                      )
                    : Text(
                        '$number',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isToday
                              ? brand.background
                              : brand.textPrimary,
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

class _PointsHistoryList extends ConsumerWidget {
  const _PointsHistoryList();

  static const _typeIcons = <String, IconData>{
    'weekly_goal': Icons.emoji_events_rounded,
    'streak_bonus': Icons.local_fire_department_rounded,
    'redeem': Icons.card_giftcard_rounded,
    'manual_adjustment': Icons.edit_rounded,
    'referral': Icons.people_rounded,
  };

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (diff < 7) return 'Hace $diff días';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final historyAsync = ref.watch(pointsHistoryProvider);

    return historyAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => AppCard(
        child: Text(
          'No se pudo cargar el historial',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (history) {
        if (history.isEmpty) {
          return AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: brand.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tu historial de puntos aparecerá aquí cuando '
                    'cumplas tu meta semanal o canjees recompensas.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            for (final entry in history)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: entry.delta > 0
                              ? brand.occupancyLow.withValues(alpha: 0.15)
                              : brand.occupancyHigh.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _typeIcons[entry.type] ?? Icons.stars_rounded,
                          size: 18,
                          color: entry.delta > 0
                              ? brand.occupancyLow
                              : brand.occupancyHigh,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.description,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: brand.textPrimary,
                              ),
                            ),
                            Text(
                              _formatDate(entry.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: brand.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        entry.delta > 0 ? '+${entry.delta}' : '${entry.delta}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: entry.delta > 0
                              ? brand.occupancyLow
                              : brand.occupancyHigh,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
