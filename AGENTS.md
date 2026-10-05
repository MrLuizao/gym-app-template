# RIR-HUB — App del socio (Flutter)

Flutter + Riverpod + Firebase (Auth, Firestore, FCM) + Stripe planeado.
Es la app del socio del gym — **nunca escribe colecciones críticas**
(`bookings`, `checkins`, `classes`, `branches.current_capacity`); todo
cambio pasa por el API del B2B vía `ApiClient` (Bearer ID token).

Repo hermano — consola de administración + backend API (Nuxt 3):
`/Users/luis/Develop/Personal/rirhub-b2b` — **ver su `AGENTS.md` y
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
con número de miembro + correo de contacto; ahí le llega un `claim_pin`
de 6 dígitos. El usuario entra con Google/Apple y reclama su ficha en
`claim_member_screen.dart` → `POST /api/members/claim` (número + PIN,
single-use). Si no le llega el código, recepción lo regenera desde el
detalle del socio en el B2B. Sin vínculo no ve datos del gym.

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

### Avatares (sin fotos)

- **Socio** — `MemberAvatar` (`core/widgets/member_avatar.dart`):
  catálogo icono+gradiente, `users/{doc}.avatar` editable desde el
  perfil (`AvatarPickerSheet`); sin avatar → iniciales.
- **Coach** — `CoachAvatar` (`core/widgets/coach_avatar.dart`): SVG
  locales `assets/avatars/coaches/{id}.svg` (flutter_svg), el id lo
  asigna el B2B al crear/editar el coach (`trainers.avatar`).
- `photo_url` de members/trainers ya no se renderiza.

### Lealtad — objetivos y recompensas

- `features/rewards/rewards_screen.dart` — pantalla propia accesible
  desde la card "Racha semanal" del home y desde Perfil
  ("Objetivos y recompensas"). Muestra puntos, meta semanal editable
  (2–6 visitas), progreso por día, catálogo `/rewards` y canjes.
- Datos reales: `users/{id}/visits/{yyyy-mm-dd}` (lo escribe el
  backend en check-in concedido — la app solo lee) +
  `users.{weekly_goal|points|goal_awarded_week}`.
- `weekly_goal` sí es escribible por el socio (whitelist en rules);
  `points` solo se mueven en el backend (`+50` al cumplir la meta).
- Canje → `POST /api/rewards/redeem` `{rewardId}` → código `RWR-XXXXXX`
  que el socio muestra en recepción (vigente 30 días).
- Sin Firebase: modo demo con meta local (`demoWeeklyGoalProvider`),
  `mockVisitDates()` y `mockRewards`.

### Métricas de aliados

`POST /api/ads/track` registra impresiones/taps de anuncios de sponsors.

### Soporte (chat con recepción)

- `features/support/support_chat_screen.dart` — "Ayuda y soporte" del
  perfil. La conversación (`conversations/{id}` + `messages`) se crea
  **perezosa** en el primer envío (`POST /api/support/conversations`), no
  al abrir la pantalla. Mensajes via `ApiClient`; lectura por stream
  Firestore (rules restringen al `member_id` propio).
- Staff resuelve → el doc se borra; un 404 al enviar reinicia el id y
  recrea en el siguiente mensaje.
- Notificaciones: el socio se suscribe al topic `member_{memberId}`
  (`syncTopics`); respuesta de staff → push con `data.type='support'`
  → `supportRequests` del `PushNotificationService` → MainShell abre el
  chat (también en cold start). Campanita del HomeHeader =
  `supportStateProvider` (unread de `unread_member`), tap abre el chat.

## Convenciones

- Riverpod `Notifier`/`FutureProvider.family` para estado; streams de
  Firestore para datos en vivo (reservas, aforo).
- Errores del API → `ApiException(statusCode, body)` — mostrar
  `SnackBar` genérico en español ("No se pudo completar la reserva").
- Branding: `context.brand` da `brand.accent/surface/cardBorder/...` —
  no hardcodear colores.
- Locale México (`es-MX`), fechas de ocurrencia en `YYYY-MM-DD` (la
  misma llave que el server calcula en `America/Mexico_City`).

### Pagos (Stripe)

- `features/payments/checkout_screen.dart`: elige plan →
  `POST /api/payments/intent` → `Stripe.instance.initPaymentSheet` +
  `presentPaymentSheet` → éxito muestra confirmación; el webhook del B2B
  activa la membresía y el stream de `users/{uid}` la refleja en vivo.
- `membershipProvider` deriva plan/status/expira de `users/{uid}`;
  `plansProvider` lee `/plans` (Firestore, `active == true`).
- Android: `MainActivity` extiende `FlutterFragmentActivity` y los temas
  son `Theme.MaterialComponents.*` — **requisitos de flutter_stripe**,
  no revertir.
- `app_bootstrap` setea `Stripe.publishableKey` desde
  `AppConfig.stripePublishableKey` — vacío = checkout muestra aviso de
  "no configurado".

## Pendientes conocidos

- **IDs de plataforma**: `com.rirhub.app` (Android applicationId +
  iOS bundle ID — renombrados desde `com.luis.prototipo_gym`/
  `com.luis.prototipoGym`). Los registros Firebase nuevos son
  `android:ce047705326905239d01a7` / `ios:6b4e298e8b3374349d01a7`;
  los viejos (`prototipo_gym`) quedaron en el proyecto y se pueden
  borrar en Console cuando se confirme que todo corre.
- **App Check**: el cliente activa Play Integrity (Android) / DeviceCheck
  (iOS — registrado en Console con `AuthKey_848YS4NF3K.p8` + team
  `FWU6W4844Y`) en `app_bootstrap.dart` — debug usa los providers de
  depuración (registrar el token que imprime la consola en Firebase
  Console → App Check → Apps). **Web no activado** (requeriría reCAPTCHA
  — decisión tomada). Para que muerda de verdad falta en Firebase
  Console: registrar la app Android con Play Integrity + la SHA-256 de
  firma, y prender **enforcement** por producto (Firestore, Auth).
- **SHA de firma (Android)**: el SHA-1 del debug keystore ya está
  registrado en la app nueva (Google Sign-In). Al firmar release, agregar
  el SHA-1/256 del keystore de producción en la app `rirhub` de Console.
- **bookings stream**: acotado a `class_date >= hoy` — usa el índice
  compuesto `(auth_uid, class_date)` ya deployado; reservas pasadas no se
  releen.

- **Stripe keys**: flujo completo; falta `stripePublishableKey`
  (`app_config.dart`, `pk_test_...`) y las secret del B2B.
- Ver "Deuda conocida" en el `AGENTS.md` del B2B para pendientes
  compartidos (cron close-day, bookings sin TTL, etc.).
