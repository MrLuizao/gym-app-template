import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/coupon.dart';
import '../../../data/models/promo.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/gym_repositories.dart';

final promotionsProvider = StreamProvider<List<Promo>>((ref) {
  final branchId = ref.watch(memberProvider).value?.branchId;
  return ref.watch(catalogRepositoryProvider).watchPromotions(branchId);
});

final couponsProvider = StreamProvider<List<Coupon>>((ref) {
  final branchId = ref.watch(memberProvider).value?.branchId;
  return ref.watch(catalogRepositoryProvider).watchCoupons(branchId);
});

final availableCouponsProvider = Provider<List<Coupon>>((ref) {
  final member = ref.watch(memberProvider).value;
  final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
  return coupons
      .where((coupon) => coupon.allowsPlan(member?.planId ?? ''))
      .toList();
});

final lockedCouponsProvider = Provider<List<Coupon>>((ref) {
  final member = ref.watch(memberProvider).value;
  final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
  return coupons
      .where((coupon) => !coupon.allowsPlan(member?.planId ?? ''))
      .toList();
});

/// Cupones que el socio generó desde el detalle de un aliado.
/// Clave = adId (un cupón por anuncio).
/// TODO(Firebase): persistir en `/members/{uid}/coupons`.
class GeneratedCouponsNotifier extends Notifier<Map<String, Coupon>> {
  @override
  Map<String, Coupon> build() => const {};

  Coupon generate(String adId, Coupon coupon) {
    return state[adId] ?? (state = {...state, adId: coupon})[adId]!;
  }
}

final generatedCouponsProvider =
    NotifierProvider<GeneratedCouponsNotifier, Map<String, Coupon>>(
      GeneratedCouponsNotifier.new,
    );
