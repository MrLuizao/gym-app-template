import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../mock/mock_data.dart';
import '../models/coupon.dart';
import '../models/gym_class.dart';
import '../models/promo.dart';
import '../models/trainer.dart';

abstract class CatalogRepository {
  Future<List<GymClass>> fetchClasses(String branchId);
  Future<List<Trainer>> fetchTrainers(String branchId);
  Stream<List<Promo>> watchPromotions();
  Stream<List<Coupon>> watchCoupons();
}

class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<List<GymClass>> fetchClasses(String branchId) async {
    final snapshot = await _db
        .collection('branches')
        .doc(branchId)
        .collection('classes')
        .orderBy('start_minutes')
        .get();
    return snapshot.docs
        .map((doc) => GymClass.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<Trainer>> fetchTrainers(String branchId) async {
    final snapshot = await _db
        .collection('branches')
        .doc(branchId)
        .collection('trainers')
        .where('is_on_duty', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => Trainer.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<Promo>> watchPromotions() {
    return _db.collection('promotions').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Promo.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<Coupon>> watchCoupons() {
    return _db
        .collection('promotions')
        .where('type', isEqualTo: 'coupon')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Coupon.fromMap(doc.id, doc.data()))
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
  Stream<List<Promo>> watchPromotions() async* {
    yield mockPromos;
  }

  @override
  Stream<List<Coupon>> watchCoupons() async* {
    yield mockCoupons;
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return AppConfig.useFirebase
      ? FirestoreCatalogRepository()
      : MockCatalogRepository();
});
