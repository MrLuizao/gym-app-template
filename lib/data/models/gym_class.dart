/// Firestore: `/branches/{branchId}/classes/{classId}`
class GymClass {
  const GymClass({
    required this.id,
    required this.branchId,
    required this.name,
    required this.coach,
    required this.room,
    required this.startMinutes,
    required this.endMinutes,
    this.capacity = 20,
    this.booked = 0,
    this.category = 'fuerza',
  });

  final String id;
  final String branchId;
  final String name;
  final String coach;
  final String room;
  final int startMinutes;
  final int endMinutes;
  final int capacity;
  final int booked;
  final String category;

  int get spotsLeft => (capacity - booked).clamp(0, capacity);
  bool get isFull => spotsLeft == 0;
  int get durationMinutes => endMinutes - startMinutes;

  String get timeRange => '${_hhmm(startMinutes)} – ${_hhmm(endMinutes)}';

  static String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  factory GymClass.fromMap(String id, Map<String, dynamic> map) => GymClass(
        id: id,
        branchId: map['branch_id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        coach: map['coach'] as String? ?? '',
        room: map['room'] as String? ?? '',
        startMinutes: (map['start_minutes'] as num?)?.toInt() ?? 0,
        endMinutes: (map['end_minutes'] as num?)?.toInt() ?? 0,
        capacity: (map['capacity'] as num?)?.toInt() ?? 20,
        booked: (map['booked'] as num?)?.toInt() ?? 0,
        category: map['category'] as String? ?? 'fuerza',
      );

  Map<String, dynamic> toMap() => {
        'branch_id': branchId,
        'name': name,
        'coach': coach,
        'room': room,
        'start_minutes': startMinutes,
        'end_minutes': endMinutes,
        'capacity': capacity,
        'booked': booked,
        'category': category,
      };
}
