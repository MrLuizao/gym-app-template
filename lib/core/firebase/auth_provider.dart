import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
