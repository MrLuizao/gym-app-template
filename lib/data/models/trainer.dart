/// Firestore: `/branches/{branchId}/trainers/{trainerId}`
class Trainer {
  const Trainer({
    required this.id,
    required this.branchId,
    required this.name,
    required this.specialty,
    this.photoUrl,
    this.avatar,
    this.shift = 'TARDE',
    this.isOnDuty = true,
  });

  final String id;
  final String branchId;
  final String name;
  final String specialty;
  final String? photoUrl;

  /// Avatar prediseñado (`assets/avatars/coaches/{id}.svg`) — elegido
  /// al crear el coach en el B2B. Reemplaza a photoUrl.
  final String? avatar;
  final String shift;
  final bool isOnDuty;

  String get initials => name
      .split(' ')
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0])
      .join()
      .toUpperCase();

  factory Trainer.fromMap(String id, Map<String, dynamic> map) => Trainer(
    id: id,
    branchId:
        map['branch_id'] as String? ??
        (map['branch_ids'] as List<dynamic>?)?.firstOrNull?.toString() ??
        '',
    name: map['name'] as String? ?? '',
    specialty: map['specialty'] as String? ?? '',
    photoUrl: map['photo_url'] as String?,
    avatar: map['avatar'] as String?,
    shift: map['shift'] as String? ?? 'TARDE',
    isOnDuty: map['is_on_duty'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'branch_id': branchId,
    'name': name,
    'specialty': specialty,
    'photo_url': photoUrl,
    'avatar': avatar,
    'shift': shift,
    'is_on_duty': isOnDuty,
  };
}
