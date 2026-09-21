class AppConfig {
  AppConfig._();

  static const bool useFirebase = false;

  static const String demoUserId = 'demo-user-001';
  static const String qrSigningKey = 'prototipo-gym-dev-key';
  static const Duration qrTokenTtl = Duration(seconds: 45);
}
