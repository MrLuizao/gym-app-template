import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/api_client.dart';
import '../../rewards/providers/loyalty_providers.dart';

class AiCoachData {
  const AiCoachData({
    required this.bestHour,
    required this.bestHourWindow,
    required this.bestHourOccupancyPct,
    required this.usualHour,
    required this.usualHourLabel,
    required this.usualHourOccupancyPct,
    required this.branchName,
    required this.currentGoal,
    required this.suggestedGoal,
    required this.habitReason,
    required this.coachTip,
    required this.aiPowered,
  });

  factory AiCoachData.fromJson(Map<String, dynamic> json) {
    return AiCoachData(
      bestHour: (json['bestHour'] as num?)?.toInt() ?? 16,
      bestHourWindow: json['bestHourWindow'] as String? ?? '16:00 - 17:00',
      bestHourOccupancyPct:
          (json['bestHourOccupancyPct'] as num?)?.toInt() ?? 38,
      usualHour: (json['usualHour'] as num?)?.toInt() ?? 18,
      usualHourLabel: json['usualHourLabel'] as String? ?? '18:00',
      usualHourOccupancyPct:
          (json['usualHourOccupancyPct'] as num?)?.toInt() ?? 84,
      branchName: json['branchName'] as String? ?? 'tu sede',
      currentGoal: (json['currentGoal'] as num?)?.toInt() ?? 4,
      suggestedGoal: (json['suggestedGoal'] as num?)?.toInt(),
      habitReason: json['habitReason'] as String?,
      coachTip:
          json['coachTip'] as String? ??
          'Entrena hoy en horario de baja demanda para completar tu rutina sin esperas.',
      aiPowered: json['aiPowered'] == true,
    );
  }

  final int bestHour;
  final String bestHourWindow;
  final int bestHourOccupancyPct;
  final int usualHour;
  final String usualHourLabel;
  final int usualHourOccupancyPct;
  final String branchName;
  final int currentGoal;
  final int? suggestedGoal;
  final String? habitReason;
  final String coachTip;
  final bool aiPowered;
}

final aiCoachProvider = FutureProvider<AiCoachData>((ref) async {
  if (!AppConfig.firebaseActive) {
    final demoGoal = ref.watch(demoWeeklyGoalProvider);
    final visited = ref.watch(weekVisitedDaysProvider);
    final visits = visited.length;
    final suggested = demoGoal >= 4 && visits < 2 ? demoGoal - 1 : null;

    return AiCoachData(
      bestHour: 16,
      bestHourWindow: '16:00 - 17:00',
      bestHourOccupancyPct: 36,
      usualHour: 18,
      usualHourLabel: '18:00',
      usualHourOccupancyPct: 86,
      branchName: 'Sede Polanco',
      currentGoal: demoGoal,
      suggestedGoal: suggested,
      habitReason: suggested != null
          ? 'Ajustar tu meta a $suggested días esta semana te facilitará asegurar el bono de +50 pts.'
          : null,
      coachTip:
          'Sueles entrenar a las 18:00 (86% aforo hoy). Si vas entre 16:00 - 17:00 entrenarás con solo 36% de ocupación.',
      aiPowered: true,
    );
  }

  final json = await ApiClient.get('/api/members/ai-coach');
  return AiCoachData.fromJson(json);
});
