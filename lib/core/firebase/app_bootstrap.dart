import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';
import 'push_notification_service.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (AppConfig.stripePublishableKey.isNotEmpty) {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
    }
    if (!AppConfig.useFirebase) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kIsWeb) {
        /// Completa un sign-in por redirect pendiente (Google en web
        /// navega fuera y vuelve — sin esto la sesión se pierde).
        try {
          await FirebaseAuth.instance.getRedirectResult();
        } catch (error) {
          debugPrint('Redirect sign-in falló: $error');
        }
      }
      await PushNotificationService.initialize();
    } catch (error) {
      debugPrint('Firebase no disponible, se continúa con datos mock: $error');
    }
  }
}
