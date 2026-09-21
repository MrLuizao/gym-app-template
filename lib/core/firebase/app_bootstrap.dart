import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!AppConfig.useFirebase) return;
    try {
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint('Firebase no disponible, se continúa con datos mock: $error');
    }
  }
}
