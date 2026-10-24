import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../data/repositories/gym_repositories.dart';
import '../../rewards/providers/loyalty_providers.dart';
import '../../shell/bottom_nav_provider.dart';
import '../providers/ai_coach_provider.dart';
import 'ai_coach_chat_sheet.dart';

/// Racha semanal y meta con Coach IA integrado:
/// - Muestra el avance hacia el bono semanal (+50 pts)
/// - Desglose de días Lun-Dom
/// - Módulo de IA: mejor ventana horaria hoy, aforo y ajuste inteligente de meta
class WeeklySummarySection extends ConsumerStatefulWidget {
  const WeeklySummarySection({super.key});

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  ConsumerState<WeeklySummarySection> createState() =>
      _WeeklySummarySectionState();
}

class _WeeklySummarySectionState extends ConsumerState<WeeklySummarySection> {
  bool _applyingGoal = false;

  Future<void> _applySuggestedGoal(int suggestedGoal) async {
    if (_applyingGoal) return;
    setState(() => _applyingGoal = true);
    try {
      await setWeeklyGoal(ref, suggestedGoal);
      ref.invalidate(aiCoachProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meta semanal ajustada a $suggestedGoal días. ¡Vamos por esos +50 pts!',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _applyingGoal = false);
      }
    }
  }

  String _buildAiContextTip(AiCoachData coach) {
    final crowdDiff = coach.usualHourOccupancyPct - coach.bestHourOccupancyPct;
    if (crowdDiff >= 12 && coach.usualHour != coach.bestHour) {
      return 'Tu hora habitual (${coach.usualHourLabel}) tendrá ~${coach.usualHourOccupancyPct}% de ocupación. En esta ventana entrenas con menor saturación en ${coach.branchName}.';
    }
    if (coach.habitReason != null && coach.habitReason!.isNotEmpty) {
      return coach.habitReason!;
    }
    return 'Horario con baja afluencia estimada en ${coach.branchName}. Momento ideal para completar tu rutina sin esperas.';
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    final goal = AppConfig.firebaseActive
        ? (member?.weeklyGoal ?? 4)
        : ref.watch(demoWeeklyGoalProvider);
    final visited = ref.watch(weekVisitedDaysProvider);
    final coachAsync = ref.watch(aiCoachProvider);

    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday = now.subtract(Duration(days: todayIndex));
    final visits = visited.where((d) => d <= todayIndex).length;
    final remaining = (goal - visits).clamp(0, goal);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: brand.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Racha y meta semanal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: brand.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(bottomNavIndexProvider.notifier).go(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BadgeChip(
                      label: '$visits/$goal VISITAS',
                      color: brand.accent,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: brand.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
              Expanded(
                child: Text(
                  remaining == 0
                      ? 'Meta semanal cumplida — ¡Bono de +50 pts asegurado!'
                      : 'Te ${remaining == 1 ? 'falta 1 visita' : 'faltan $remaining visitas'} para tu meta de $goal por semana',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: brand.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
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
                    label: WeeklySummarySection._dayLabels[i],
                    number: monday.add(Duration(days: i)).day,
                    visited: visited.contains(i),
                    isToday: i == todayIndex,
                    isFuture: i > todayIndex,
                  ),
                ),
              ],
            ],
          ),
          if (AppConfig.enableAiCoachInsights)
            coachAsync.maybeWhen(
              data: (coach) {
              final crowdDiff =
                  coach.usualHourOccupancyPct - coach.bestHourOccupancyPct;
              final savesCrowd =
                  crowdDiff >= 10 && coach.usualHour != coach.bestHour;
              final bestHourColor =
                  brand.occupancyFor(coach.bestHourOccupancyPct / 100);

              return Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      brand.accent.withValues(alpha: 0.08),
                      brand.background,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: brand.accent.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brand.accent.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: Chip Coach IA + Sede + Badge de aforo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: brand.accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: brand.accent.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 13,
                                color: brand.accent,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'COACH IA',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: brand.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            coach.branchName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: brand.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: bestHourColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: bestHourColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bestHourColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '~${coach.bestHourOccupancyPct}% AFORO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: bestHourColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tarjeta destacada: Ventana horaria óptima con ahorro
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: brand.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: brand.cardBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: brand.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 19,
                              color: brand.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VENTANA RECOMENDADA HOY',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: brand.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  coach.bestHourWindow,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                    color: brand.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (savesCrowd)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: brand.occupancyLow.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '-$crowdDiff%',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                      color: brand.occupancyLow,
                                    ),
                                  ),
                                  Text(
                                    'AFORO',
                                    style: TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: brand.occupancyLow,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Gráfica comparativa visual de barras (solo si hay diferencia clara)
                    if (savesCrowd) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Hora habitual (${coach.usualHourLabel})',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: brand.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '~${coach.usualHourOccupancyPct}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: brand.occupancyHigh,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (coach.usualHourOccupancyPct / 100)
                                          .clamp(0.0, 1.0),
                                      minHeight: 4,
                                      backgroundColor: brand.surface,
                                      valueColor: AlwaysStoppedAnimation(
                                        brand.occupancyHigh
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ventana IA (${coach.bestHour.toString().padLeft(2, '0')}:00)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: brand.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '~${coach.bestHourOccupancyPct}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: brand.occupancyLow,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (coach.bestHourOccupancyPct / 100)
                                          .clamp(0.0, 1.0),
                                      minHeight: 4,
                                      backgroundColor: brand.surface,
                                      valueColor: AlwaysStoppedAnimation(
                                        brand.occupancyLow,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Insight inteligente contextual
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 14,
                          color: brand.accent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _buildAiContextTip(coach),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: brand.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Botón interactivo de ajuste de meta
                    if (coach.suggestedGoal != null &&
                        coach.suggestedGoal != coach.currentGoal) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: brand.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: brand.accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _applyingGoal
                                ? null
                                : () => _applySuggestedGoal(coach.suggestedGoal!),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 15,
                                    color: brand.accent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _applyingGoal
                                        ? 'Ajustando meta...'
                                        : 'Calibrar meta a ${coach.suggestedGoal} días/sem (Recomendado)',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: brand.accent,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (AppConfig.enableAiCoachChat) ...[
                      const SizedBox(height: 12),

                      // Botón interactivo: Platicar con Coach de Bolsillo
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              brand.accent.withValues(alpha: 0.18),
                              brand.accent.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: brand.accent.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => AiCoachChatSheet.show(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          brand.accent.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 17,
                                      color: brand.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Consultar al Coach de Bolsillo',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w900,
                                                color: brand.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons.fiber_manual_record,
                                              size: 7,
                                              color: brand.occupancyLow,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          'Pregunta sobre tu rutina, técnica o nutrición',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                            color: brand.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: brand.accent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
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
