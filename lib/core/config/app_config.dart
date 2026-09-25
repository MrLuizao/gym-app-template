import 'package:firebase_core/firebase_core.dart';

class AppConfig {
  AppConfig._();

  static const bool useFirebase = true;

  /// Firebase disponible de verdad (inicializado en runtime).
  /// En tests o si el bootstrap falló, la app corre en modo demo/mock.
  static bool get firebaseActive => useFirebase && Firebase.apps.isNotEmpty;

  /// Backend Nuxt (B2B) — endpoints con lógica de negocio:
  /// /api/ads/track, /api/payments/intent, etc.
  /// En dev con emulador Android usar http://10.0.2.2:3000
  static const String apiBaseUrl = 'https://gym-b2b-template.vercel.app';
  // static const String apiBaseUrl = 'http://localhost:3000'; 

  // 'http://10.0.2.2:3000' (Android emu). En dispositivo físico el
  // localhost es el propio teléfono — usar la IP LAN de la Mac y
  // levantar el B2B con `npm run dev -- --host` para que acepte LAN.
  // static const String apiBaseUrl = 'http://192.168.100.8:3000';

  /// Stripe publishable key (pk_test_... / pk_live_...) — la app cobra
  /// con Payment Sheet; vacío = checkout deshabilitado.
  static const String stripePublishableKey = 'pk_test_51UJPcdIWbzJbgGWCNjP6HCELAjY6AZzOWUASX16aUCiZ4d9Rfjp5ErPBTc5L3plWSEZI6ROg2Deg4dXZisuT3bGK001ZXTE0R6';

  /// OAuth web client (auto-creado por Firebase) — el flujo Google en
  /// web va por FedCM y necesita el clientId explícito.
  static const String googleWebClientId =
      '1081337347174-pcgs538lrc9121pln4tki132iius1ur6.apps.googleusercontent.com';

  static const String demoUserId = 'demo-user-001';
  static const String qrSigningKey = 'prototipo-gym-dev-key';
  static const Duration qrTokenTtl = Duration(seconds: 45);
}
