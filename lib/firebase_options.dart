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
    appId: '1:1081337347174:android:ce047705326905239d01a7',
    messagingSenderId: '1081337347174',
    projectId: 'rir-hub',
    storageBucket: 'rir-hub.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChA9pVf1ppamA7pqV_e86QDKNCmSESZ2o',
    appId: '1:1081337347174:ios:6b4e298e8b3374349d01a7',
    messagingSenderId: '1081337347174',
    projectId: 'rir-hub',
    storageBucket: 'rir-hub.firebasestorage.app',
    androidClientId:
        '1081337347174-amukb7jv0ti7nmhpajgm5f0f91h8f49b.apps.googleusercontent.com',
    iosClientId:
        '1081337347174-ruaeevqh2vdm7m1hn149a4pcfcoipq4n.apps.googleusercontent.com',
    iosBundleId: 'com.rirhub.app',
  );
}
