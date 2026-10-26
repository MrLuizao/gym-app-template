# RIR-HUB — App del socio (Flutter)

Flutter + Riverpod + Firebase (Auth, Firestore, FCM) + Stripe planeado.
Es la app del socio del gym — **nunca escribe colecciones críticas**
(`bookings`, `checkins`, `classes`, `branches.current_capacity`); todo
cambio pasa por el API del B2B vía `ApiClient` (Bearer ID token).

Repo hermano — consola de administración + backend API (Nuxt 3):
`/Users/luis/Develop/Personal/rirhub-b2b` — **ver su `AGENTS.md` y
`FIRESTORE.md` para modelo de datos, endpoints y matriz de roles.**

## ⚡ Regla de Oro de Agilidad y Pruebas

- **NO ejecutar pruebas unitarias (`flutter test`, etc.) de forma automática**: Las pruebas solo se realizan **cuando el usuario lo indique expresamente**. No correr suites de prueba ni comandos largos por iniciativa propia.
- **Flujo de trabajo ágil y directo**: Resolver solicitudes con modificaciones concisas, precisas y directas al código. Evitar diagnósticos redundantes, pasos intermedios innecesarios o procesos largos.
- **Validación ligera de sintaxis**: La única verificación tras cambios de código es confirmar que no existan errores de compilación (`flutter analyze`), manteniéndolo ágil y sin bloquear al usuario con esperas innecesarias.

## Comandos

```bash
flutter analyze   # verificación rápida de sintaxis (debe quedar en 0 issues)
flutter run       # ejecutar la app en emulador o dispositivo
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
- `lib/features/` — por pantalla: `home`, `explore`, `allies`, `promos`,
  `rewards`, `profile`, `branch_detail`, `checkin`, `trainers`,
  `auth`, `onboarding`, `payments`, `metrics`, `sponsor_detail`, `shell`
- Bottom nav (`shell/main_shell.dart`): 0 Inicio · 1 Explorar · 2 Aliados
  · 3 Promos · 4 Premios — el Perfil NO es tab; se abre tocando el avatar
  del header del Home (push → `profile_screen` como modal). El `target`
  de los push mapea a los índices de tab.

## Flujos clave

### Alta de socio (claim)

La app **no crea** el registro del socio — recepción lo crea en el B2B
con número de miembro + correo de contacto; ahí le llega un `claim_pin`
de 6 dígitos. El usuario entra con Google/Apple y reclama su ficha en
`claim_member_screen.dart` → `POST /api/members/claim` (número + PIN,
single-use).
- El campo de número viene **precargado con `CF-`** mediante
  `_MemberNumberFormatter`: el usuario no puede borrar el prefijo, se
  abre directamente el teclado numérico (`TextInputType.number`) y se
  normaliza automáticamente a 5 dígitos (`CF-00000`).
- Si no le llega el código, recepción lo regenera desde el detalle del
  socio en el B2B. Sin vínculo no ve datos del gym.

### Home: Racha Semanal y Coach IA Unificado

`WeeklySummarySection` (`features/home/widgets/weekly_summary_card.dart`)
integra en una sola tarjeta compacta el progreso del socio y la IA:
- **Progreso y racha**: Barra de avance semanal y pastillas de los 7 días (Lun–Dom)
  para conseguir el bono de +50 pts de lealtad.
- **Coach IA (`/api/members/ai-coach`)**: Identifica la hora habitual del socio y
  muestra la **mejor ventana horaria hoy** con menor aforo estimado en su sede favorita.
- **Ajuste inteligente de meta (1-tap)**: Si la IA detecta que le conviene ajustar
  su meta para salvar la racha o escalar su objetivo, despliega la acción recomendada
  sin repetir texto de visitas.

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

### Perfil y ajustes

- `profile_screen.dart` — se abre al tocar el avatar del HomeHeader
  (no es tab del bottom nav). Muestra membresía, renovación y menú
  Cuenta (pagos, soporte, legal, logout).
- **Notificaciones**: los toggles viven en
  `features/profile/settings_screen.dart` ("Ajustes") — accesible desde
  Perfil → Cuenta → "Notificaciones". Mantenerlos fuera de la vista
  principal es intencional: evita que el socio los desactive sin querer
  (son canal comercial del gym).

### Lealtad — objetivos y recompensas

- `features/rewards/rewards_screen.dart` — tab propio del bottom nav
  ("Premios"). Muestra puntos, meta semanal editable
  (2–6 visitas), progreso por día, catálogo `/rewards`, canjes e
  historial de puntos.
- Datos reales: `users/{id}/visits/{yyyy-mm-dd}` (lo escribe el
  backend en check-in concedido — la app solo lee) +
  `users.{weekly_goal|points|goal_awarded_week}`.
- `weekly_goal` sí es escribible por el socio (whitelist en rules);
  `points` solo se mueven en el backend (`+50` al cumplir la meta).
- Canje → `POST /api/rewards/redeem` `{rewardId}` → código `RWR-XXXXXX`
  que el socio muestra en recepción (vigente 30 días). Al canjear llega
  push de confirmación; 3 días antes de expirar llega recordatorio.
- **Historial de puntos**: `pointsHistoryProvider` →
  `GET /api/rewards/history` — últimos 50 movimientos. Modelo
  `PointsHistoryEntry` en `data/models/reward.dart`. La pantalla muestra
  cada movimiento con ícono por tipo, delta (+/-) y fecha relativa.
- **Racha extendida**: el backend otorga puntos extra por semanas
  consecutivas cumpliendo la meta (2 sem +25, 4 sem +50, 8 sem +100,
  12 sem +150) — el historial lo refleja como entrada `streak_bonus`.
- Sin Firebase: modo demo con meta local (`demoWeeklyGoalProvider`),
  `mockVisitDates()` y `mockRewards`; historial con datos ficticios.

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

## Estética Luxury (estilo Spotify) y Micro-interacciones

Toda nueva pantalla, modal o componente en la app **debe mantener el estándar visual y táctil de lujo (inspirado en Spotify)** implementado en el sistema de diseño:

1. **Luz ambiental superior (Ambient Radial Glow)**:
   - Las pantallas principales (`HomeScreen`, `ExploreScreen`, `AlliesScreen`, `PromotionsScreen`, `RewardsScreen`, `ProfileScreen`, `BranchDetailScreen`) envuelven su contenido en un `Stack` con un `RadialGradient` superior (`brand.accent` con `alpha: 0.14–0.22` hacia transparente).
   - En `HomeScreen`, el halo cambia dinámicamente a verde esmeralda (`brand.occupancyLow`) cuando el socio cumple su meta semanal (`visits >= goal`).
2. **Física táctil universal (`PressableScale` + `AppHaptics`)**:
   - **Nunca usar `GestureDetector` plano sin feedback visual** en tarjetas, píldoras, botones o chips interactivos. Envolver siempre en `PressableScale` (`lib/core/widgets/pressable_scale.dart`), que aplica compresión elástica (`Curves.easeOutCubic` / `Curves.elasticOut`).
   - **Regla de Vibraciones Hápticas**: `PressableScale` tiene `enableHaptic: false` por defecto — **NO usar vibración háptica en navegaciones hacia atrás ni en navegaciones hacia adelante genéricas** (con **excepción del tap en tarjetas de Aliados / Club de beneficios y cupones**, que sí llevan `enableHaptic: true` / `AppHaptics`). Reservar las vibraciones exclusivamente para **recompensas importantes y acciones de valor** (tap en aliados/beneficios, canje de recompensas y cupones, cumplimiento de meta semanal, marcar sede favorita ❤️, seguir/dejar de seguir entrenador, abrir pase QR, confirmar pago y confirmar cierre de sesión).
3. **Jerarquía de respuestas hápticas (`lib/core/utils/haptics.dart`)**:
   - `AppHaptics.light()` / `enableHaptic: true`: Tap en tarjetas de Aliados (`SponsorCarousel`, `_AllyCard`, `CouponCard`).
   - `AppHaptics.selection()`: Ajuste de meta semanal (`2–6`), copiar códigos de recompensa o cupón al portapapeles.
   - `AppHaptics.medium()`: Acciones de valor (canjear beneficio/recompensa, abrir pase QR `CheckInSheet` / `CouponQrSheet`, marcar sede favorita, seguir entrenador, reservar clase).
   - `AppHaptics.heavy()`: Éxito de vinculación/check-in (`AuthSuccessScreen`), pago completado, canje de recompensa confirmado, confirmación de cierre de sesión, o error con sacudida horizontal (`ClaimMemberScreen`).
4. **Bottom Navigation (`MainShell` + `MainBottomBar`)**:
   - Barra fija de 5 tabs con cristal esmerilado (`ClipRRect` + `BackdropFilter(ImageFilter.blur(sigmaX: 18, sigmaY: 18))` + superficie translúcida `alpha: 0.92`).
   - Íconos `outlined` en reposo que transicionan a `filled` al activarse con escala elástica (sin rayita inferior bajo el texto y **sin vibración háptica al cambiar de tab**).
   - Transición suave entre pestañas (`FadeTransition` + `SlideTransition` sutil).
5. **Indicadores vivos y contadores animados**:
   - **Pulso en vivo**: Las sedes abiertas (`BranchCard`) y el estado activo del QR (`CheckInSheet`) muestran un punto con halo respiratorio (`AnimationController` en repeat reverse).
   - **Contadores numéricos (`TweenAnimationBuilder`)**: Los números de visitas semanales (`WeeklySummarySection`) y el saldo de puntos (`RewardsScreen`) animan su conteo progresivo y destellan cuando suben.
   - **Cascada de racha**: Las 7 pastillas de días (`Lun–Dom`) entran en cascada escalonada y las completadas brillan con `BoxShadow` del color de acento.
6. **Launch, Onboarding y Vinculación (`ClaimMemberScreen`)**:
   - `GymApp` presenta un `_LuxurySplashView` (~720ms) con emblema respirando y pulso háptico antes de revelar `Home` u `Onboarding` con `AnimatedSwitcher`.
   - `OnboardingScreen` usa `PageView` deslizable con barras de progreso superiores tipo *Story* y fondo con halo en paralaje.
   - `ClaimMemberScreen` usa **6 casillas individuales táctiles** para el `claim_pin` con glow en foco, auto-avance, soporte de pegado de 6 dígitos, auto-submit al 6º dígito y sacudida horizontal (`shake`) + `AppHaptics.heavy()` si el código falla.

## Convenciones

- Riverpod `Notifier`/`FutureProvider.family` para estado; streams de
  Firestore para datos en vivo (reservas, aforo).
- Errores del API → `ApiException(statusCode, body)` — mostrar
  `SnackBar` genérico en español ("No se pudo completar la reserva").
- Branding: `context.brand` da `brand.accent/surface/cardBorder/...` —
  no hardcodear colores.
- **Contraste en colores de marca de aliados (`ad.brandColor` / `brand.allyAccent`)**:
  Un anunciante puede elegir tonos oscuros o terrosos (ej. café, verde olivo, azul marino). **Nunca pintar textos ni íconos directamente con `allyColor` sobre fondos oscuros** porque se pierden: usar siempre **`Colors.white`** (o `brand.readableOn(allyColor)` sobre rellenos sólidos) para íconos y textos, y reservar el `allyColor` para **rellenos de píldoras/botones (`Color.alphaBlend`), bordes iluminados, sombras y halos ambientales**.
- Locale México (`es-MX`), fechas de ocurrencia en `YYYY-MM-DD` (la
  misma llave que el server calcula en `America/Mexico_City`).

### Pagos (Stripe)

- `features/payments/checkout_screen.dart`: elige plan →
  `POST /api/payments/intent` → `Stripe.instance.initPaymentSheet` +
  `presentPaymentSheet` → éxito muestra confirmación; el webhook del B2B
  activa la membresía y el stream de `users/{uid}` la refleja en vivo.
- **Regla de Nivel / Upgrade para Membresías Activas**:
  - El nivel de un plan lo define su `price` (orden ascendente en `plansProvider`).
  - Si la membresía del socio está **activa y vigente** (`membershipStatus == ACTIVE` y no vencida), **solo puede subir de nivel (upgrade)** (`plan.price > currentPlan.price`).
  - Los planes de menor nivel (`plan.price < currentPlan.price`) y su plan actual (`plan.id == currentPlan.id` o `plan.price == currentPlan.price`) aparecen bloqueados en `MembershipCheckoutScreen` (`NIVEL INFERIOR` / `TU PLAN ACTUAL`), y `POST /api/payments/intent` en el B2B rechaza con `400` cualquier intento de pagar un plan de precio menor o igual mientras la membresía siga vigente.
  - Cuando la membresía está vencida (`EXPIRED` o fecha pasada), el socio puede elegir libremente cualquier plan para renovar.
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

- **QR firmado rotativo = código muerto**: `QrPassCard` +
  `qrTokenProvider` (+ `verifyQrToken`/`QR_SIGNING_KEY` en el B2B)
  están implementados pero **nadie los usa** — el check-in real es el
  `CheckInSheet` con el número de socio en QR plano. Si se reactiva:
  firmar server-side (la key compilada en el binario no es secreta y
  debe igualar la env de Vercel) y validar frescura de `issuedAt`.
- **Stripe keys**: flujo completo; falta `stripePublishableKey`
  (`app_config.dart`, `pk_test_...`) y las secret del B2B.
- Ver "Deuda conocida" en el `AGENTS.md` del B2B para pendientes
  compartidos (cron close-day, bookings sin TTL, etc.).
