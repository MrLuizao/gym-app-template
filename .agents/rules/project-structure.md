# Estructura del Proyecto — RIR-HUB App (Flutter)

## Distribución de Directorios

```
rirhub-app/
├── lib/
│   ├── core/                   # Núcleo y utilidades compartidas
│   │   ├── config/             # app_config.dart (apiBaseUrl, demo mode)
│   │   ├── firebase/           # api_client.dart, auth_provider.dart, push_notification_service.dart
│   │   ├── theme/              # Paleta dark y tipografía
│   │   └── widgets/            # MemberAvatar, CoachAvatar, botones comunes
│   ├── data/                   # Capa de datos
│   │   ├── models/             # Modelos Dart (GymClass, Member, Reward, etc.)
│   │   ├── repositories/       # Repositorios Firestore (lectura)
│   │   └── mock/               # Datos en memoria para modo demo sin Firebase
│   └── features/               # Pantallas organizadas por feature
│       ├── auth/               # Login social (Google/Apple) y selector de sede
│       ├── onboarding/         # Claim de cuenta con PIN
│       ├── shell/              # main_shell.dart (BottomNavigationBar)
│       ├── home/               # Dashboard socio + Coach IA + resumen semanal
│       ├── explore/            # Sedes y catálogo de clases
│       ├── branch_detail/      # Detalle de sede + reserva por ocurrencia
│       ├── allies/             # Directorio de aliados comerciales
│       ├── promos/             # Promociones y carrusel de descuentos
│       ├── rewards/            # Puntos, racha y canje de premios
│       ├── profile/            # Perfil (modal desde HomeHeader) y ajustes
│       ├── checkin/            # Pantalla con QR para acceso
│       └── support/            # Chat socio-staff
├── assets/                     # SVGs de coaches, logos, fuentes
├── AGENTS.md                   # Fuente de verdad de la app móvil
└── pubspec.yaml                # Dependencias (flutter, riverpod, firebase, etc.)
```

## Navegación y Shell

- **Bottom Navigation Tabs** (`shell/main_shell.dart`):
  - Index 0: **Inicio** (`home`)
  - Index 1: **Explorar** (`explore`)
  - Index 2: **Aliados** (`allies`)
  - Index 3: **Promos** (`promos`)
  - Index 4: **Premios** (`rewards`)
- **Perfil**: **NO** es un tab del bottom nav. Se abre como ruta modal al tocar el avatar en el header de Home (`HomeHeader`).
- **Mapeo de Pushes**: Los payloads de FCM con `target` (`home`, `explore`, `allies`, `promos`, `rewards`) conmutan automáticamente al índice respectivo del shell.
