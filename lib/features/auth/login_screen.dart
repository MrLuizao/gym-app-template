import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../app.dart';
import '../../core/branding/brand.dart';
import '../../core/firebase/auth_provider.dart';
import '../../core/firebase/google_sign_in_button_stub.dart'
    if (dart.library.js_interop)
        '../../core/firebase/google_sign_in_button_web.dart';

/// Login del socio — registro self-service con Google/Apple.
/// El doc /users/{uid} en Firestore define membresía, sede y número;
/// si no existe, el gate manda a completar perfil.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  /// Google/Apple — el gate de auth en app.dart navega solo.
  Future<void> _socialSignIn(
    Future<void> Function() signIn,
    String provider,
  ) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await signIn();
      await _afterSignIn();
    } on GoogleSignInException catch (e) {
      /// El usuario cerró el sheet — no es error.
      if (e.code != GoogleSignInExceptionCode.canceled) {
        setState(() => _error = 'No se pudo entrar con $provider');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        setState(() => _error = 'No se pudo entrar con $provider');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = 'No se pudo entrar con $provider (${e.code})');
    } catch (_) {
      setState(() => _error = 'No se pudo entrar con $provider');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Cuando esta pantalla se abrió empujada desde el onboarding hay
  /// que reemplazar la ruta por el gate — si viene del propio gate
  /// (canPop == false) el stream de auth navega solo.
  Future<void> _afterSignIn() async {
    if (!mounted || !Navigator.of(context).canPop()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    /// En web el botón GIS completa el sign-in sin callback — al llegar
    /// la sesión por authState navegamos como tras el login por correo.
    ref.listen(authStateProvider, (_, next) {
      if (next.value != null && mounted) _afterSignIn();
    });
    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -110,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    brand.accent.withValues(alpha: 0.3),
                    brand.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -130,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    brand.accentDark.withValues(alpha: 0.4),
                    brand.accentDark.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: brand.accent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: brand.accent.withValues(alpha: 0.35),
                              blurRadius: 32,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: brand.background,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      brand.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.5,
                        color: brand.accent,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ENTRENA.\nRESERVA.\nREPITE.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: brand.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      brand.tagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: brand.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    /// Un botón por plataforma: web exige el oficial de
                    /// Google (FedCM); iOS → Apple; Android → Google.
                    if (kIsWeb)
                      Center(child: googleSignInWebButton())
                    else if (Platform.isIOS)
                      _SocialButton(
                        label: 'Continuar con Apple',
                        icon: Icons.apple_rounded,
                        onTap: () => _socialSignIn(
                          () => ref
                              .read(authControllerProvider)
                              .signInWithApple(),
                          'Apple',
                        ),
                      )
                    else
                      _SocialButton(
                        label: 'Continuar con Google',
                        icon: Icons.g_mobiledata_rounded,
                        onTap: () => _socialSignIn(
                          () => ref
                              .read(authControllerProvider)
                              .signInWithGoogle(),
                          'Google',
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: brand.occupancyHigh,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text(
                      '¿Aún no eres socio? Regístrate en recepción —\nte darán tu número de miembro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: brand.textPrimary),
      label: Text(
        label,
        style: TextStyle(color: brand.textPrimary, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(color: brand.cardBorder),
        backgroundColor: brand.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
