import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/coupon.dart';
import '../../../data/models/promo.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/gym_repositories.dart';

final promotionsProvider = StreamProvider<List<Promo>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchPromotions();
});

final couponsProvider = StreamProvider<List<Coupon>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchCoupons();
});

final availableCouponsProvider = Provider<List<Coupon>>((ref) {
  final member = ref.watch(memberProvider).value;
  final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
  final level = member?.membershipLevel ?? 'CLASSIC';
  return coupons.where((coupon) => coupon.allowsLevel(level)).toList();
});

final lockedCouponsProvider = Provider<List<Coupon>>((ref) {
  final member = ref.watch(memberProvider).value;
  final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
  final level = member?.membershipLevel ?? 'CLASSIC';
  return coupons.where((coupon) => !coupon.allowsLevel(level)).toList();
});

class RedeemedCouponsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void redeem(String couponId) {
    state = <String>{...state, couponId};
  }
}

final redeemedCouponsProvider =
    NotifierProvider<RedeemedCouponsNotifier, Set<String>>(
  RedeemedCouponsNotifier.new,
);
