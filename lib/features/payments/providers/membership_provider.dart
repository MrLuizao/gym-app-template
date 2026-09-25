import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../data/repositories/gym_repositories.dart';

class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.price,
    this.tag,
  });

  final String id;
  final String name;
  final double price;
  final String? tag;

  factory MembershipPlan.fromMap(String id, Map<String, dynamic> map) =>
      MembershipPlan(
        id: id,
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        tag: map['highlight'] == true ? 'DESTACADO' : null,
      );
}

const fallbackPlans = <MembershipPlan>[
  MembershipPlan(id: 'classic', name: 'Plan Classic', price: 199),
  MembershipPlan(id: 'plus', name: 'Plan Plus', price: 299, tag: 'MÁS POPULAR'),
  MembershipPlan(
    id: 'black',
    name: 'Plan Black',
    price: 399,
    tag: 'TODO INCLUIDO',
  ),
  MembershipPlan(id: 'select', name: 'Plan Select', price: 249),
  MembershipPlan(id: 'xpress', name: 'Plan Xpress', price: 149),
];

/// Cache module-level para que `planNameFor` (síncrono) resuelva sin
/// async — lo llena `plansProvider` al primer watch.
List<MembershipPlan> _plansCache = fallbackPlans;

/// Catálogo real de planes desde /plans (Firestore). Se ordena por
/// precio en cliente — un orderBy server-side pediría un índice
/// compuesto (active + price) y el stream fallaría en silencio.
final plansProvider = StreamProvider<List<MembershipPlan>>((ref) {
  if (!AppConfig.firebaseActive) return Stream.value(fallbackPlans);
  return FirebaseFirestore.instance
      .collection('plans')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snap) {
        final plans = snap.docs
            .map((doc) => MembershipPlan.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.price.compareTo(b.price));
        if (plans.isNotEmpty) _plansCache = plans;
        return plans.isEmpty ? fallbackPlans : plans;
      });
});

/// Resuelve el nombre del plan desde el catálogo — solo para display.
String planNameFor(String planId) {
  for (final plan in _plansCache) {
    if (plan.id == planId) return plan.name;
  }
  return planId.isEmpty ? 'Sin plan' : planId;
}

class MembershipState {
  const MembershipState({
    required this.planId,
    required this.status,
    this.expiresAt,
  });

  final String planId;
  final String status;
  final DateTime? expiresAt;

  bool get isActive => status == 'ACTIVE';
}

/// Membresía del socio — derivada en vivo de /users/{uid}.
/// La webhook de Stripe la actualiza al confirmarse el cobro.
final membershipProvider = Provider<MembershipState>((ref) {
  final member = ref.watch(memberProvider).value;
  return MembershipState(
    planId: member?.planId ?? '',
    status: member?.membershipStatus ?? 'EXPIRED',
    expiresAt: member?.membershipUntil,
  );
});

double planPrice(MembershipPlan plan) => plan.price;
