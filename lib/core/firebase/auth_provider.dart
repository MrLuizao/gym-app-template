import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Sesión del socio — Firebase Auth es la fuente de verdad.
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(FirebaseAuth.instance),
);

class AuthController {
  const AuthController(this._auth);

  final FirebaseAuth _auth;

  /// Registro/login con Google — google_sign_in v7 usa singleton
  /// `instance` + `authenticate()`; el idToken se cambia por
  /// credencial de Firebase.
  Future<UserCredential?> signInWithGoogle() async {
    /// En web el plugin google_sign_in va por FedCM y exige clientId —
    /// el popup de Firebase Auth funciona sin configuración extra.
    if (kIsWeb) {
      try {
        return await _auth.signInWithPopup(GoogleAuthProvider());
      } catch (_) {
        /// El SDK web a veces rechaza la promesa en su reload interno
        /// (getAccountInfo/_reloadWithoutSaving) aunque el sign-in ya
        /// completó — si currentUser existe, la sesión es válida.
        if (_auth.currentUser == null) rethrow;
        return null;
      }
    }
    await GoogleSignIn.instance.initialize();
    final account = await GoogleSignIn.instance.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  /// Registro/login con Apple (nativo en iOS). Apple solo entrega el
  /// nombre en el PRIMER consentimiento — hay que guardarlo ahí mismo.
  Future<UserCredential> signInWithApple() async {
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      accessToken: apple.authorizationCode,
    );
    final result = await _auth.signInWithCredential(credential);
    final name = [
      apple.givenName,
      apple.familyName,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' ');
    if (name.isNotEmpty && (result.user?.displayName?.isEmpty ?? true)) {
      await result.user?.updateDisplayName(name);
    }
    return result;
  }

  /// Email/password — útil para cuentas demo/staff en desarrollo.
  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
