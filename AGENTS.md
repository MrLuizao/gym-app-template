# Prototipo Gym — App del socio (Flutter)

Flutter + Riverpod + Firebase (Auth, Firestore, FCM) + Stripe planeado.
Es la app del socio del gym — **nunca escribe colecciones críticas**
(`bookings`, `checkins`, `classes`, `branches.current_capacity`); todo
cambio pasa por el API del B2B vía `ApiClient` (Bearer ID token).

Repo hermano — consola de administración + backend API (Nuxt 3):
`/Users/luis/Develop/Personal/prototipo-gym-b2b` — **ver su `AGENTS.md` y
`FIRESTORE.md` para modelo de datos, endpoints y matriz de roles.**

## Comandos

```bash
flutter analyze   # debe quedar en 0 issues
flutter run       # tras cambios de plugins/gradle: rebuild completo
```

## Configuración

- `lib/core/config/app_config.dart`: `apiBaseUrl` apunta a
  `http://localhost:3000` en dev (prod: dominio Vercel del B2B).
  `firebaseActive` = `useFirebase && Firebase.apps.isNotEmpty` — sin
  Firebase la app corre en modo demo en memoria.
- `firebase_options.dart` + `google-services.json` (Android) configurados.

## Estructura

- `lib/core/` — branding (white-label desde `/config/brand`), config,
  firebase (`api_client`, `auth_provider`, `push_notification_service`,
  `app_bootstrap`), theme, widgets compartidos
- `lib/data/` — models (Firestore snake_case ↔ Dart), repositories
  (queries de solo lectura a Firestore), mock (fallback demo)
- `lib/features/` — por pantalla: `home`, `explore`, `allies`, `promos`
  (Descuentos), `profile`, `branch_detail`, `checkin`, `trainers`,
  `auth`, `onboarding`, `payments`, `metrics`, `sponsor_detail`, `shell`
- Bottom nav (`shell/main_shell.dart`): 0 Inicio · 1 Explorar · 2 Aliados
  · 3 Descuentos · 4 Perfil — el `target` de los push mapea a estos índices

## Flujos clave

### Alta de socio (claim)

La app **no crea** el registro del socio — recepción lo crea en el B2B
con número de miembro + teléfono. El usuario entra con Google/Apple y
reclama su ficha en `claim_member_screen.dart` → `POST /api/members/claim`
(número + teléfono). Sin vínculo no ve datos del gym.

### Reservas de clase — por ocurrencia

- `reservedClassesProvider` (`branch_detail/providers/reservation_provider.dart`)
  es un `Set` claveado `'classId|YYYY-MM-DD'` — una reserva es por fecha,
  no por clase. Stream de `bookings` donde `auth_uid == uid`,
  `status == 'confirmed'` (viejas sin `class_date` cuentan por `created_at`).
- `toggle(classId, date:, branchId:)` → `POST /api/classes/{id}/book`
  `{date, branchId}` / `DELETE .../book?date=` — el server valida
  membresía ACTIVE, fecha `[hoy, hoy+8]`, vigencia horaria (con
  `branch_times` de la sede) y cupo en transacción.
- `GymClass` (`data/models/gym_class.dart`): `bookedByDate` es
  `{fecha: {branchId: n}}` — cupo por fecha **y sede** (la clase usa su
  `branchId` de contexto; `'_'` = conteo legacy). `booked` solo es
  fallback para docs viejos. Helpers: `bookedFor/spotsLeftFor/
  isFullFor/endedFor(date)` + `dateKey(DateTime)`.
- El selector de 7 días en `branch_detail_screen` define la fecha de
  reserva — pásala siempre a `ClassTile`, `ClassDetailSheet.show` y
  `toggle`. Clase terminada hoy → tile "TERMINADA" / botón deshabilitado.
- Clases multi-sede: `branch_times[branchId]` sobreescribe
  horario/sala — resuélvelo siempre con la sede en contexto.

### Check-in y aforo

- QR en `features/checkin` — el socio muestra su QR, recepción escanea;
  `POST /api/checkin` concede/rechaza (aforo lleno, membresía, etc.).
- `branches.current_capacity` se lee directo de Firestore (badge de aforo
  en vivo). El socio nunca lo escribe; recepción ajusta desde el B2B.
- Auto-checkout del server libera check-ins >90 min; close-day barre todo
  a `dailyStats` — la app no hace nada de esto.

### Push (FCM)

- `push_notification_service.dart`: suscripción a topics
  (`all_members`, `branch_{id}`), foreground en Android via
  `flutter_local_notifications` (canal `push_channel` "Notificaciones",
  requiere desugaring — ya configurado en `build.gradle.kts`), iOS via
  `setForegroundNotificationPresentationOptions`.
- Tap → `data['target']` → tab del shell (`auto`/faltante → por `kind`:
  SPONSOR→Aliados, BRAND→Descuentos). Android necesita el intent-filter
  `FLUTTER_NOTIFICATION_CLICK` en `MainActivity` (ya agregado) para que
  `onMessageOpenedApp` dispare.

### Métricas de aliados

`POST /api/ads/track` registra impresiones/taps de anuncios de sponsors.

## Convenciones

- Riverpod `Notifier`/`FutureProvider.family` para estado; streams de
  Firestore para datos en vivo (reservas, aforo).
- Errores del API → `ApiException(statusCode, body)` — mostrar
  `SnackBar` genérico en español ("No se pudo completar la reserva").
- Branding: `context.brand` da `brand.accent/surface/cardBorder/...` —
  no hardcodear colores.
- Locale México (`es-MX`), fechas de ocurrencia en `YYYY-MM-DD` (la
  misma llave que el server calcula en `America/Mexico_City`).

## Pendientes conocidos

- **Stripe**: `POST /api/payments/intent` existe en el B2B; flujo de
  cobro en app sin completar (`features/payments`).
- Ver "Deuda conocida" en el `AGENTS.md` del B2B para pendientes
  compartidos (cron close-day, bookings sin TTL, etc.).
