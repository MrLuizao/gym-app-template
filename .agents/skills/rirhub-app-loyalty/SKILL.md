---
name: rirhub-app-loyalty
description: >-
  Use this skill when working on the Rewards screen (features/rewards),
  weekly goal slider, points balance, points history, or redeeming reward codes in Flutter.
---

# Rewards & Loyalty System (Flutter)

## Pantalla: `features/rewards/rewards_screen.dart`
Es el tab 4 ("Premios") del Bottom Navigation Bar.

### Elementos Principales:
1. **Saldo de Puntos y Racha**:
   - Muestra `users/{id}.points` (saldo actual).
   - Indicador de racha consecutiva (`goal_streak` semanas) y bonificaciones obtenidas.
2. **Meta Semanal (`weekly_goal`)**:
   - Slider o selector numérico (entre 2 y 6 visitas semanales).
   - Es uno de los pocos campos con permiso de auto-escritura en Firestore:
     ```dart
     await FirebaseFirestore.instance
         .collection('users')
         .doc(uid)
         .update({'weekly_goal': newGoal});
     ```
3. **Progreso Semanal**:
   - Días visitados en la semana actual (Lun-Dom) calculados leyendo la subcolección `users/{id}/visits/{yyyy-mm-dd}`.
   - Al alcanzar la meta, el backend acredita +50 puntos automáticamente al procesar el check-in.
4. **Catálogo de Premios y Canje**:
   - Colección pública `/rewards` (items con `active == true`).
   - Botón de canje invoca:
     ```dart
     POST /api/rewards/redeem
     body: {'rewardId': reward.id}
     ```
   - Retorna un código único formato `RWR-XXXXXX` que expira en 30 días.
   - El código se almacena en `users/{id}/redemptions` y se muestra en una tarjeta o diálogo para validación en recepción.
5. **Historial de Movimientos**:
   - Proveedor: `pointsHistoryProvider` llama a `GET /api/rewards/history`.
   - Mapea a `List<PointsHistoryEntry>` con tipo de movimiento (`goal_met`, `streak_bonus`, `redemption`), cantidad (+/- puntos) y fecha relativa.
