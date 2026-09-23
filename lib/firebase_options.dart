// File generated manually — equivalent to FlutterFire CLI output.
// Regenerate with: flutterfire configure --project=rir-hub
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBE_kyOkeOLo6TKjKfS0Z9r-Xhib0jWSKQ',
    appId: '1:1081337347174:web:795cea254a6e8b989d01a7',
    messagingSenderId: '1081337347174',
    projectId: 'rir-hub',
    authDomain: 'rir-hub.firebaseapp.com',
    storageBucket: 'rir-hub.firebasestorage.app',
    measurementId: 'G-24KFBLXC4E',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnJ4nfUvkkqQwhKAA7KMOPgqCjAGBdAoU',
    appId: '1:1081337347174:android:55f347ac0ae7e4209d01a7',
    messagingSenderId: '1081337347174',
    projectId: 'rir-hub',
    storageBucket: 'rir-hub.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChA9pVf1ppamA7pqV_e86QDKNCmSESZ2o',
    appId: '1:1081337347174:ios:74c0853adc874d0a9d01a7',
    messagingSenderId: '1081337347174',
    projectId: 'rir-hub',
    storageBucket: 'rir-hub.firebasestorage.app',
    iosBundleId: 'com.luis.prototipoGym',
  );
}
