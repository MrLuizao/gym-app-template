# Convenciones de Código — RIR-HUB App (Flutter)

## ⚡ Regla de Oro: Agilidad y Pruebas
- **NO ejecutar pruebas unitarias (`flutter test`, etc.) de forma automática**: Solo cuando el usuario lo solicite explícitamente.
- **Flujo ágil y directo**: Modificaciones directas, precisas y concisas.
- **Validación ligera de sintaxis**: La única verificación tras cambios es `flutter analyze` (debe quedar en 0 issues).

## Arquitectura y Estado (Riverpod)
- State management con **Riverpod** (StateNotifierProvider, FutureProvider, StreamProvider).
- Separación de capas:
  - `lib/core/`: Config, clientes de API, servicios singleton (FCM, auth).
  - `lib/data/`: Modelos (`fromFirestore`, `toJson`) y repositorios de solo lectura.
  - `lib/features/`: Pantallas y widgets agrupados por feature.
- **Inmutabilidad**: Modelos inmutables con métodos `copyWith` cuando sea necesario.

## Escritura de Datos y Firestore
- **La app NUNCA escribe colecciones críticas directamente en Firestore**:
  - `bookings`, `checkins`, `classes`, `branches.current_capacity` **NO se escriben desde Flutter**.
  - Todo cambio pasa obligatoriamente por el API del B2B vía `ApiClient` (`POST /api/...`) usando Bearer ID token.
- **Campos escribibles por el socio en Firestore (whitelist en rules)**:
  - `users/{id}.avatar`: Id del catálogo `memberAvatarCatalog`.
  - `users/{id}.weekly_goal`: Meta semanal (entre 2 y 6 días).

## UI / UX
- **Tema**: Dark mode predominante con colores de marca obtenidos de `/config/brand` (white-label).
- **Idioma**: Español (México) para todos los textos de la interfaz.
- **Avatares**:
  - Socio: Usar `MemberAvatar` (`core/widgets/member_avatar.dart`), icono lucide + gradiente. No se usa `photo_url`.
  - Coach: Usar `CoachAvatar` (`core/widgets/coach_avatar.dart`), SVG local en `assets/avatars/coaches/`.
