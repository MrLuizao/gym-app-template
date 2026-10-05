import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';
import 'push_notification_service.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!kIsWeb && AppConfig.stripePublishableKey.isNotEmpty) {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      await Stripe.instance.applySettings();
    }
    if (!AppConfig.useFirebase) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (!kIsWeb) {
        /// App Check: Play Integrity (Android) / DeviceCheck (iOS).
        /// En debug se usa el provider de depuración (registrar el token
        /// impreso en consola en Firebase Console → App Check). Web no
        /// se activa — requeriría reCAPTCHA. La enforcement se prende en
        /// la consola de Firebase por producto (Firestore, Auth, etc.).
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleDeviceCheckProvider(),
        );
      }
      if (kIsWeb) {
        /// En web el sign-in de Google va por el botón oficial GIS
        /// (FedCM): popup/redirect pierden la sesión por las políticas
        /// de storage de terceros de Chrome. Los eventos del botón se
        /// convierten aquí en credencial Firebase.
        await GoogleSignIn.instance.initialize(
          clientId: AppConfig.googleWebClientId,
        );
        GoogleSignIn.instance.authenticationEvents.listen((event) async {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            final credential = GoogleAuthProvider.credential(
              idToken: event.user.authentication.idToken,
            );
            await FirebaseAuth.instance.signInWithCredential(credential);
          }
        });
      }
      await PushNotificationService.initialize();
    } catch (error) {
      debugPrint('Firebase no disponible, se continúa con datos mock: $error');
    }
  }
}
