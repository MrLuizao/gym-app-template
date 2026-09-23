import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../models/coupon.dart';
import '../models/gym_class.dart';
import '../models/promo.dart';
import '../models/sponsor_ad.dart';
import '../models/trainer.dart';

abstract class CatalogRepository {
  Future<List<GymClass>> fetchClasses(String branchId);
  Future<List<Trainer>> fetchTrainers(String branchId);
  Stream<List<Promo>> watchPromotions(String? branchId);
  Stream<List<Coupon>> watchCoupons(String? branchId);
  Stream<List<SponsorAd>> watchSponsorAds(String? branchId);
}

bool _isFutureOrNull(dynamic ts) {
  if (ts == null) return true;
  final ms = ts is Timestamp ? ts.millisecondsSinceEpoch : ts as num?;
  return ms == null || ms.toInt() > DateTime.now().millisecondsSinceEpoch;
}

bool _targetsBranch(Map<String, dynamic> map, String? branchId) {
  final docBranch = map['branch_id'];
  return branchId == null || docBranch == null || docBranch == branchId;
}

class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<List<GymClass>> fetchClasses(String branchId) async {
    /// Clases top-level con branch_ids[] + overrides por sede en
    /// branch_times[branchId] (horario/sala locales).
    final snapshot = await _db
        .collection('classes')
        .where('branch_ids', arrayContains: branchId)
        .get();
    final classes = snapshot.docs
        .map((doc) => GymClass.fromMap(doc.id, doc.data(), branchId: branchId))
        .toList();
    classes.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return classes;
  }

  @override
  Future<List<Trainer>> fetchTrainers(String branchId) async {
    final snapshot = await _db
        .collection('trainers')
        .where('branch_ids', arrayContains: branchId)
        .where('is_on_duty', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => Trainer.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<Promo>> watchPromotions(String? branchId) {
    return _db
        .collection('promotions')
        .where('type', isEqualTo: 'banner')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where(
                (doc) =>
                    _isFutureOrNull(doc.data()['expires_at']) &&
                    _targetsBranch(doc.data(), branchId),
              )
              .map((doc) => Promo.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<Coupon>> watchCoupons(String? branchId) {
    return _db
        .collection('promotions')
        .where('type', isEqualTo: 'coupon')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where(
                (doc) =>
                    _isFutureOrNull(doc.data()['expires_at']) &&
                    _targetsBranch(doc.data(), branchId),
              )
              .map((doc) => Coupon.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<SponsorAd>> watchSponsorAds(String? branchId) {
    return _db
        .collection('sponsorAds')
        .where('status', isEqualTo: 'ACTIVE')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where(
                (doc) =>
                    _isFutureOrNull(doc.data()['ends_at']) &&
                    _targetsBranch(doc.data(), branchId),
              )
              .map((doc) => SponsorAd.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<GymClass>> fetchClasses(String branchId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return mockClasses;
  }

  @override
  Future<List<Trainer>> fetchTrainers(String branchId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return mockTrainers;
  }

  @override
  Stream<List<Promo>> watchPromotions(String? branchId) async* {
    yield mockPromos;
  }

  @override
  Stream<List<Coupon>> watchCoupons(String? branchId) async* {
    yield mockCoupons;
  }

  @override
  Stream<List<SponsorAd>> watchSponsorAds(String? branchId) async* {
    yield mockSponsorAds;
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return AppConfig.firebaseActive
      ? FirestoreCatalogRepository()
      : MockCatalogRepository();
});
