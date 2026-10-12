import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore: `/rewards/{rewardId}` — catálogo fijo sembrado por el B2B.
/// `icon` mapea a un Material icon en la app (no se guardan imágenes).
class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    this.icon = 'gift',
    required this.active,
  });

  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String icon;
  final bool active;

  factory Reward.fromMap(String id, Map<String, dynamic> map) {
    return Reward(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      pointsCost: (map['points_cost'] as num?)?.toInt() ?? 0,
      icon: map['icon'] as String? ?? 'gift',
      active: map['active'] as bool? ?? true,
    );
  }
}

/// Movimiento de puntos — `/users/{id}/pointsHistory/{docId}`.
/// Lo escribe el backend en cada ganancia/gasto de puntos.
class PointsHistoryEntry {
  const PointsHistoryEntry({
    required this.id,
    required this.type,
    required this.delta,
    required this.balance,
    required this.description,
    this.refId,
    this.createdAt,
  });

  final String id;

  /// `weekly_goal` | `streak_bonus` | `redeem` | `manual_adjustment` | `referral`
  final String type;

  /// Cambio (+/-) en puntos.
  final int delta;

  /// Saldo resultante después del movimiento.
  final int balance;

  /// Texto legible del movimiento.
  final String description;

  /// Referencia opcional (redemptionId, etc.).
  final String? refId;

  final DateTime? createdAt;

  factory PointsHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PointsHistoryEntry(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'manual_adjustment',
      delta: (json['delta'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      refId: json['refId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['createdAt'] as num).toInt(),
            )
          : null,
    );
  }
}

/// Firestore: `/users/{userId}/redemptions/{id}` — escribe solo el
/// backend (`POST /api/rewards/redeem`). `status`: 'active' | 'used'
/// | 'expired'.
class RewardRedemption {
  const RewardRedemption({
    required this.id,
    required this.rewardId,
    required this.rewardName,
    required this.pointsSpent,
    required this.code,
    required this.status,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String rewardId;
  final String rewardName;
  final int pointsSpent;
  final String code;
  final String status;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  bool get isActive =>
      status == 'active' &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  factory RewardRedemption.fromMap(String id, Map<String, dynamic> map) {
    final created = map['created_at'];
    final expires = map['expires_at'];
    return RewardRedemption(
      id: id,
      rewardId: map['reward_id'] as String? ?? '',
      rewardName: map['reward_name'] as String? ?? 'Recompensa',
      pointsSpent: (map['points_spent'] as num?)?.toInt() ?? 0,
      code: map['code'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      createdAt: created is Timestamp ? created.toDate() : null,
      expiresAt: expires is Timestamp
          ? expires.toDate()
          : expires is DateTime
          ? expires
          : null,
    );
  }
}
