/// Firestore: `/branches/{branchId}/trainers/{trainerId}`
class Trainer {
  const Trainer({
    required this.id,
    required this.branchId,
    required this.name,
    required this.specialty,
    this.photoUrl,
    this.shift = 'TARDE',
    this.isOnDuty = true,
  });

  final String id;
  final String branchId;
  final String name;
  final String specialty;
  final String? photoUrl;
  final String shift;
  final bool isOnDuty;

  factory Trainer.fromMap(String id, Map<String, dynamic> map) => Trainer(
        id: id,
        branchId: map['branch_id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        specialty: map['specialty'] as String? ?? '',
        photoUrl: map['photo_url'] as String?,
        shift: map['shift'] as String? ?? 'TARDE',
        isOnDuty: map['is_on_duty'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'branch_id': branchId,
        'name': name,
        'specialty': specialty,
        'photo_url': photoUrl,
        'shift': shift,
        'is_on_duty': isOnDuty,
      };
}
