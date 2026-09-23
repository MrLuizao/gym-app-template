import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore: `/promotions/{couponId}` con `type: 'coupon'`
/// `plan_ids`: ids de planes con acceso ('ALL' | `/plans/{planId}`).
class Coupon {
  const Coupon({
    required this.id,
    required this.brandId,
    required this.title,
    required this.description,
    required this.badge,
    required this.code,
    required this.planIds,
    this.branchId,
    this.expiresAt,
  });

  final String id;
  final String brandId;
  final String title;
  final String description;
  final String badge;
  final String code;
  final List<String> planIds;
  final String? branchId;
  final DateTime? expiresAt;

  bool allowsPlan(String planId) =>
      planIds.contains('ALL') || planIds.contains(planId);

  factory Coupon.fromMap(String id, Map<String, dynamic> map) {
    final expires = map['expires_at'];
    return Coupon(
      id: id,
      brandId: map['brand_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      badge: map['badge'] as String? ?? '',
      code: map['code'] as String? ?? '',
      planIds: (map['plan_ids'] as List<dynamic>? ?? const <dynamic>[])
          .map((plan) => plan.toString())
          .toList(),
      branchId: map['branch_id'] as String?,
      expiresAt: expires is Timestamp
          ? expires.toDate()
          : expires is num
          ? DateTime.fromMillisecondsSinceEpoch(expires.toInt())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'brand_id': brandId,
    'title': title,
    'description': description,
    'badge': badge,
    'code': code,
    'plan_ids': planIds,
    'branch_id': branchId,
    'expires_at': expiresAt?.millisecondsSinceEpoch,
  };
}
