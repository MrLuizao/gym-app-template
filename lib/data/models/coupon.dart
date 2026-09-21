/// Firestore: `/promotions/{couponId}` con `type: 'coupon'`
/// `levels`: niveles de membresía con acceso ('ALL' | 'CLASSIC' | 'PLUS' | 'BLACK')
class Coupon {
  const Coupon({
    required this.id,
    required this.brandId,
    required this.title,
    required this.description,
    required this.badge,
    required this.code,
    required this.levels,
    this.branchId,
    this.expiresAt,
  });

  final String id;
  final String brandId;
  final String title;
  final String description;
  final String badge;
  final String code;
  final List<String> levels;
  final String? branchId;
  final DateTime? expiresAt;

  bool allowsLevel(String level) =>
      levels.contains('ALL') || levels.contains(level.toUpperCase());

  String get minLevelLabel => levels.contains('ALL') ? 'TODOS' : levels.join(' · ');

  factory Coupon.fromMap(String id, Map<String, dynamic> map) {
    final expires = map['expires_at'];
    return Coupon(
      id: id,
      brandId: map['brand_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      badge: map['badge'] as String? ?? '',
      code: map['code'] as String? ?? '',
      levels: (map['levels'] as List<dynamic>? ?? const <dynamic>[])
          .map((level) => level.toString().toUpperCase())
          .toList(),
      branchId: map['branch_id'] as String?,
      expiresAt: expires is num
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
        'levels': levels,
        'branch_id': branchId,
        'expires_at': expiresAt?.millisecondsSinceEpoch,
      };
}
