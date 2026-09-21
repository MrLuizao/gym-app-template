/// Firestore: `/users/{userId}`
/// `membership_status`: 'ACTIVE' | 'EXPIRED'
/// `membership_level`: 'CLASSIC' | 'PLUS' | 'BLACK'
class Member {
  const Member({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.membershipStatus,
    this.qrCode = '',
    this.memberNumber = '',
    this.plan = '',
    this.membershipLevel,
    this.membershipUntil,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String membershipStatus;
  final String qrCode;
  final String memberNumber;
  final String plan;
  final String? membershipLevel;
  final DateTime? membershipUntil;

  bool get isActive => membershipStatus == 'ACTIVE';

  String get level => membershipLevel ?? deriveLevel(plan);

  String get initials => name
      .split(' ')
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0])
      .join()
      .toUpperCase();

  static String deriveLevel(String plan) {
    final normalized = plan.toLowerCase();
    if (normalized.contains('black')) return 'BLACK';
    if (normalized.contains('plus')) return 'PLUS';
    return 'CLASSIC';
  }

  factory Member.fromMap(String id, Map<String, dynamic> map) {
    final until = map['membership_until'];
    final plan = map['plan'] as String? ?? '';
    return Member(
      id: id,
      name: map['name'] as String? ?? 'Socio',
      photoUrl: map['photo_url'] as String?,
      membershipStatus: map['membership_status'] as String? ?? 'EXPIRED',
      qrCode: map['qr_code'] as String? ?? '',
      memberNumber: map['member_number'] as String? ?? '',
      plan: plan,
      membershipLevel: map['membership_level'] as String?,
      membershipUntil: until is num
          ? DateTime.fromMillisecondsSinceEpoch(until.toInt())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'photo_url': photoUrl,
        'membership_status': membershipStatus,
        'membership_level': membershipLevel ?? deriveLevel(plan),
        'qr_code': qrCode,
        'member_number': memberNumber,
        'plan': plan,
        'membership_until': membershipUntil?.millisecondsSinceEpoch,
      };
}
