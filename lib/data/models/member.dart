import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore: `/users/{userId}`
/// `membership_status`: 'ACTIVE' | 'EXPIRED'
/// `membership_plan_id`: id del plan (`/plans/{planId}`) — el nombre se
/// resuelve desde el catálogo solo para display.
class Member {
  const Member({
    required this.id,
    required this.name,
    this.photoUrl,
    this.avatarId,
    required this.membershipStatus,
    this.qrCode = '',
    this.memberNumber = '',
    this.planId = '',
    this.branchId,
    this.membershipUntil,
    this.weeklyGoal = 4,
    this.points = 0,
    this.goalAwardedWeek,
  });

  final String id;
  final String name;
  final String? photoUrl;

  /// Avatar prediseñado (`memberAvatarCatalog` ids) — reemplaza a la
  /// foto de perfil: el socio elige uno, sin imágenes subidas.
  final String? avatarId;
  final String membershipStatus;
  final String qrCode;
  final String memberNumber;
  final String planId;
  final String? branchId;
  final DateTime? membershipUntil;

  /// Lealtad — `weekly_goal` lo edita el socio; `points` solo lo
  /// escribe el backend al cumplir la meta semanal.
  final int weeklyGoal;
  final int points;

  /// Semana (lunes `yyyy-MM-dd` CDMX) ya premiada — evita doble premio.
  final String? goalAwardedWeek;

  bool get isActive => membershipStatus == 'ACTIVE';

  String get initials => name
      .split(' ')
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0])
      .join()
      .toUpperCase();

  factory Member.fromMap(String id, Map<String, dynamic> map) {
    final until = map['membership_until'];
    return Member(
      id: id,
      name: map['name'] as String? ?? 'Socio',
      photoUrl: map['photo_url'] as String?,
      avatarId: map['avatar'] as String?,
      membershipStatus: map['membership_status'] as String? ?? 'EXPIRED',
      qrCode: map['qr_code'] as String? ?? '',
      memberNumber: map['member_number'] as String? ?? '',
      planId: map['membership_plan_id'] as String? ?? '',
      branchId: map['branch_id'] as String?,
      membershipUntil: until is Timestamp
          ? until.toDate()
          : until is num
          ? DateTime.fromMillisecondsSinceEpoch(until.toInt())
          : null,
      weeklyGoal: (map['weekly_goal'] as num?)?.toInt() ?? 4,
      points: (map['points'] as num?)?.toInt() ?? 0,
      goalAwardedWeek: map['goal_awarded_week'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'photo_url': photoUrl,
    'membership_status': membershipStatus,
    'qr_code': qrCode,
    'member_number': memberNumber,
    'membership_plan_id': planId,
    'branch_id': branchId,
    'membership_until': membershipUntil?.millisecondsSinceEpoch,
  };
}
