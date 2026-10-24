---
name: rirhub-app-bookings
description: >-
  Use this skill when working on class reservations, occurrence-based bookings,
  schedule calculations, spots left, ClassTile, ClassDetailSheet, or
  branch_times overrides in Flutter.
---

# Class Reservations by Occurrence (Flutter)

## Modelo de Reserva

Una reserva está atada a una **ocurrencia específica** (`class_id` + `class_date` en formato `YYYY-MM-DD` CDMX):
- Estado del socio en local: `reservedClassesProvider` (`branch_detail/providers/reservation_provider.dart`).
- Se almacena como un `Set<String>` de claves compuestas: `'${classId}|${dateKey}'`.
- Stream de Firestore sobre `bookings` filtrado por `auth_uid == currentUserId` y `status == 'confirmed'`.

## Interacción en UI

### 1. Selector de 7 Días
- Ubicado en `branch_detail_screen.dart`.
- La fecha seleccionada (`selectedDate`) define el contexto para todas las clases mostradas:
  - Debe pasarse a `ClassTile`, a `ClassDetailSheet.show` y al método `toggle`.
  - Si la clase ya concluyó hoy (basado en `end_minutes` / `branch_times`), se muestra el badge "TERMINADA" y se deshabilita la reserva.

### 2. Capacidad y Cupos (`GymClass`)
- Archivo: `lib/data/models/gym_class.dart`.
- `bookedByDate` es un mapa anidado: `{fecha: {branchId: int}}`.
- Helpers clave en `GymClass`:
  - `spotsLeftFor(date, branchId)`: Cupos restantes para esa fecha y sede.
  - `isFullFor(date, branchId)`: True si no quedan lugares.
  - `endedFor(date, branchId)`: True si la hora de fin ya pasó en tiempo CDMX.
  - `dateKey(DateTime date)`: Helper para formatear a `YYYY-MM-DD`.
- **Clases multi-sede**: Siempre resolver horario y sala usando `branch_times[branchId]` de la sede activa.

### 3. Mutaciones (API B2B)
- Reservar:
  ```dart
  POST /api/classes/{id}/book
  body: {'date': 'YYYY-MM-DD', 'branchId': '...'}
  ```
- Cancelar:
  ```dart
  DELETE /api/classes/{id}/book?date=YYYY-MM-DD
  ```
- La app nunca escribe en la colección `bookings` ni decrementa/incrementa cupos directo en Firestore.
