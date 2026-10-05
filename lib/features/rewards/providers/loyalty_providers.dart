import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/api_client.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/models/reward.dart';
import '../../../data/repositories/gym_repositories.dart';

/// Fecha `yyyy-MM-dd` — misma llave que el server genera en CDMX.
String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Lunes de la semana actual (la semana de lealtad empieza en lunes,
/// como la calcula `weekBounds` en el server).
DateTime weekMonday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - (now.weekday - 1));
}

/// Doc id del socio (`users/{id}` — no es el auth uid necesariamente).
final memberDocIdProvider = Provider<String?>((ref) {
  if (!AppConfig.firebaseActive) return AppConfig.demoUserId;
  return ref.watch(memberProvider).value?.id;
});

/// Días con visita registrada — `users/{id}/visits/{yyyy-MM-dd}`.
/// Devuelve las llaves de fecha; la UI las mapea a días de semana.
/// Acotado a las últimas 8 semanas (documentId >= lunes−56d) para que
/// el historial creciente no multiplique lecturas en cada apertura.
final visitDatesProvider = StreamProvider<Set<String>>((ref) {
  if (!AppConfig.firebaseActive) return Stream.value(mockVisitDates());
  final memberId = ref.watch(memberDocIdProvider);
  if (memberId == null) return Stream.value(const <String>{});
  final cutoff = dateKey(weekMonday().subtract(const Duration(days: 56)));
  return FirebaseFirestore.instance
      .collection('users')
      .doc(memberId)
      .collection('visits')
      .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoff)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.id).toSet());
});

/// Índices de días de ESTA semana con visita (0=lunes … 6=domingo).
final weekVisitedDaysProvider = Provider<Set<int>>((ref) {
  final dates = ref.watch(visitDatesProvider).value ?? const <String>{};
  final monday = weekMonday();
  final result = <int>{};
  for (final key in dates) {
    final d = DateTime.tryParse(key);
    if (d == null) continue;
    final diff = DateTime(
      d.year,
      d.month,
      d.day,
    ).difference(monday).inDays;
    if (diff >= 0 && diff < 7) result.add(diff);
  }
  return result;
});

/// Catálogo de recompensas activas — `/rewards`.
final rewardsProvider = StreamProvider<List<Reward>>((ref) {
  if (!AppConfig.firebaseActive) return Stream.value(mockRewards);
  return FirebaseFirestore.instance
      .collection('rewards')
      .where('active', isEqualTo: true)
      .snapshots()
      .map(
        (snap) =>
            snap.docs.map((doc) => Reward.fromMap(doc.id, doc.data())).toList()
              ..sort((a, b) => a.pointsCost.compareTo(b.pointsCost)),
      );
});

/// Canjes del socio — `users/{id}/redemptions`, más recientes primero.
final redemptionsProvider = StreamProvider<List<RewardRedemption>>((ref) {
  if (!AppConfig.firebaseActive) {
    return Stream.value(const <RewardRedemption>[]);
  }
  final memberId = ref.watch(memberDocIdProvider);
  if (memberId == null) return Stream.value(const <RewardRedemption>[]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(memberId)
      .collection('redemptions')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => RewardRedemption.fromMap(doc.id, doc.data()))
            .toList(),
      );
});

/// Meta semanal editable — solo demo sin Firebase; con Firebase vive
/// en `users/{id}.weekly_goal` (el stream del socio lo refleja solo).
class DemoWeeklyGoalNotifier extends Notifier<int> {
  @override
  int build() => 4;

  void setGoal(int goal) => state = goal;
}

final demoWeeklyGoalProvider = NotifierProvider<DemoWeeklyGoalNotifier, int>(
  DemoWeeklyGoalNotifier.new,
);

/// Cambia la meta semanal del socio (1–7 visitas). Campo whitelisted
/// en firestore.rules — el socio sí puede escribirlo.
Future<void> setWeeklyGoal(WidgetRef ref, int goal) async {
  if (!AppConfig.firebaseActive) {
    ref.read(demoWeeklyGoalProvider.notifier).setGoal(goal);
    return;
  }
  final memberId = ref.read(memberDocIdProvider);
  if (memberId == null) return;
  await FirebaseFirestore.instance.collection('users').doc(memberId).update({
    'weekly_goal': goal,
  });
}

/// Canje de recompensa vía API — el server valida saldo y descuenta
/// puntos en transacción; devuelve el código generado.
Future<String> redeemReward(String rewardId) async {
  final res = await ApiClient.post('/api/rewards/redeem', {
    'rewardId': rewardId,
  });
  return res['code'] as String? ?? '';
}
