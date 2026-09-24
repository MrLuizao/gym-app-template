/// Firestore: `/branches/{branchId}/classes/{classId}`
/// `coach_id`: referencia canónica al entrenador (`/trainers/{coachId}`);
/// `coach` es la etiqueta denormalizada solo para display.
class GymClass {
  const GymClass({
    required this.id,
    required this.branchId,
    required this.name,
    required this.coach,
    this.coachId = '',
    required this.room,
    required this.startMinutes,
    required this.endMinutes,
    this.capacity = 20,
    this.booked = 0,
    this.bookedByDate = const {},
    this.category = 'fuerza',
  });

  final String id;
  final String branchId;
  final String name;
  final String coach;
  final String coachId;
  final String room;
  final int startMinutes;
  final int endMinutes;
  final int capacity;

  /// Inscritos de HOY (campo `booked` del doc, compat).
  final int booked;

  /// Inscritos por fecha Y sede `booked_by_date` — `{fecha: {sede: n}}`,
  /// la fuente real del cupo por ocurrencia. La llave '_' es un conteo
  /// legacy sin sede.
  final Map<String, Map<String, int>> bookedByDate;
  final String category;

  /// Llave de fecha local `YYYY-MM-DD` — la misma que escribe el backend
  /// en `bookings.class_date` (America/Mexico_City).
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int bookedFor(String date) {
    final entry = bookedByDate[date];
    // Conteo de ESTA sede; '_' = conteo legacy sin sede.
    if (entry != null) return entry[branchId] ?? entry['_'] ?? 0;
    // Si el mapa existe, `booked` puede traer el conteo obsoleto de ayer;
    // solo se usa como fallback en docs viejos sin mapa.
    if (bookedByDate.isNotEmpty) return 0;
    return date == dateKey(DateTime.now()) ? booked : 0;
  }

  int spotsLeftFor(String date) =>
      (capacity - bookedFor(date)).clamp(0, capacity);

  bool isFullFor(String date) => spotsLeftFor(date) == 0;

  /// Vigencia: si la fecha es hoy y ya pasó la hora de fin, la clase
  /// ya no es reservable.
  bool endedFor(String date) {
    if (date != dateKey(DateTime.now()) || endMinutes <= 0) return false;
    final now = DateTime.now();
    return now.hour * 60 + now.minute >= endMinutes;
  }

  int get spotsLeft => spotsLeftFor(dateKey(DateTime.now()));
  bool get isFull => spotsLeft == 0;
  int get durationMinutes => endMinutes - startMinutes;

  String get timeRange => '${_hhmm(startMinutes)} – ${_hhmm(endMinutes)}';

  static String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  /// `branchId` resuelve el override por sede en `branch_times` —
  /// una clase multi-sede puede tener horario/sala distinto en cada una.
  factory GymClass.fromMap(
    String id,
    Map<String, dynamic> map, {
    String? branchId,
  }) {
    final overrides =
        (map['branch_times'] as Map<String, dynamic>?)?[branchId]
            as Map<String, dynamic>?;
    return GymClass(
      id: id,
      branchId: branchId ?? map['branch_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      coach: map['coach'] as String? ?? '',
      coachId: map['coach_id'] as String? ?? '',
      room: overrides?['room'] as String? ?? map['room'] as String? ?? '',
      startMinutes:
          (overrides?['start_minutes'] as num?)?.toInt() ??
          (map['start_minutes'] as num?)?.toInt() ??
          0,
      endMinutes:
          (overrides?['end_minutes'] as num?)?.toInt() ??
          (map['end_minutes'] as num?)?.toInt() ??
          0,
      capacity: (map['capacity'] as num?)?.toInt() ?? 20,
      booked: (map['booked'] as num?)?.toInt() ?? 0,
      bookedByDate:
          (map['booked_by_date'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              // Legacy: número plano → llave '_' (conteo sin sede).
              v is num
                  ? {'_': v.toInt()}
                  : (v as Map<String, dynamic>).map(
                      (k2, v2) => MapEntry(k2, (v2 as num?)?.toInt() ?? 0),
                    ),
            ),
          ) ??
          const {},
      category: map['category'] as String? ?? 'fuerza',
    );
  }

  Map<String, dynamic> toMap() => {
    'branch_id': branchId,
    'name': name,
    'coach': coach,
    'coach_id': coachId,
    'room': room,
    'start_minutes': startMinutes,
    'end_minutes': endMinutes,
    'capacity': capacity,
    'booked': booked,
    'category': category,
  };
}
