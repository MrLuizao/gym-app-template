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
import '../../core/config/app_config.dart';
import '../../core/firebase/auth_provider.dart';
import '../auth/login_screen.dart';
import '../shell/main_shell.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            AppConfig.firebaseActive ? const AuthGate() : const MainShell(),
      ),
    );
  }

  /// Sign-in social real — al éxito el AuthGate decide entre
  /// completar perfil (sin /users/{uid}) o entrar al shell.
  Future<void> _social(Future<void> Function() signIn, String provider) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await signIn();
      if (mounted) await _finish(context);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        setState(() => _error = 'No se pudo continuar con $provider');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        setState(() => _error = 'No se pudo continuar con $provider');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = 'No se pudo continuar (${e.code})');
    } catch (_) {
      setState(() => _error = 'No se pudo continuar con $provider');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final firebase = AppConfig.firebaseActive;
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
            bottom: -150,
            left: -120,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    brand.accentDark.withValues(alpha: 0.35),
                    brand.accentDark.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [brand.accent, brand.accentDark],
                      ),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 38,
                      color: brand.background,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Crea tu cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: brand.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a Capital Fitness y entrena sin límites',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: brand.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 44),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else ...[
                    _SocialButton(
                      label: 'Continuar con Google',
                      icon: Icons.g_mobiledata_rounded,
                      iconColor: const Color(0xFF4285F4),
                      filled: true,
                      onTap: () => _social(
                        () =>
                            ref.read(authControllerProvider).signInWithGoogle(),
                        'Google',
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!kIsWeb && Platform.isIOS)
                      _SocialButton(
                        label: 'Continuar con Apple',
                        icon: Icons.apple_rounded,
                        iconColor: brand.textPrimary,
                        filled: false,
                        onTap: () => _social(
                          () => ref
                              .read(authControllerProvider)
                              .signInWithApple(),
                          'Apple',
                        ),
                      ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: brand.occupancyHigh,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (firebase)
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                      child: Text(
                        'Entrar con correo',
                        style: TextStyle(
                          color: brand.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () => _finish(context),
                      child: Text(
                        'Continuar sin cuenta (demo)',
                        style: TextStyle(
                          color: brand.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Al continuar aceptas los Términos y Condiciones\ny la Política de Privacidad de Capital Fitness.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: brand.textSecondary,
                    ),
                  ),
                  const Spacer(),
                ],
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
    required this.iconColor,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: filled ? Colors.black : brand.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
