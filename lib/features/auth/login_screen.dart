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

/// Login del socio — registro self-service con Google/Apple.
/// El doc /users/{uid} en Firestore define membresía, sede y número;
/// si no existe, el gate manda a completar perfil.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _showEmailForm = false;
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

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider)
          .signIn(_email.text, _password.text);
      await _afterSignIn();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'invalid-credential' ||
          'wrong-password' ||
          'user-not-found' => 'Correo o contraseña incorrectos',
          'invalid-email' => 'Correo inválido',
          'too-many-requests' => 'Demasiados intentos — espera un momento',
          'network-request-failed' => 'Sin conexión — revisa tu internet',
          _ => 'No se pudo iniciar sesión (${e.code})',
        };
      });
    } catch (_) {
      setState(() => _error = 'No se pudo iniciar sesión');
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
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      brand.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: brand.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand.tagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: brand.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _SocialButton(
                      label: 'Continuar con Google',
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () => _socialSignIn(
                        () =>
                            ref.read(authControllerProvider).signInWithGoogle(),
                        'Google',
                      ),
                    ),
                    if (!kIsWeb && Platform.isIOS) ...[
                      const SizedBox(height: 12),
                      _SocialButton(
                        label: 'Continuar con Apple',
                        icon: Icons.apple_rounded,
                        onTap: () => _socialSignIn(
                          () => ref
                              .read(authControllerProvider)
                              .signInWithApple(),
                          'Apple',
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _showEmailForm = !_showEmailForm),
                        child: Text(
                          _showEmailForm
                              ? 'Ocultar correo'
                              : 'Entrar con correo',
                          style: TextStyle(
                            color: brand.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (!_showEmailForm) ...[
                      if (_error != null) ...[
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: brand.occupancyHigh,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ] else ...[
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        style: TextStyle(color: brand.textPrimary),
                        decoration: _fieldDecoration(
                          brand,
                          hint: 'Correo electrónico',
                          icon: Icons.mail_outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _password,
                        obscureText: _obscure,
                        style: TextStyle(color: brand.textPrimary),
                        onSubmitted: (_) => _submit(),
                        decoration: _fieldDecoration(
                          brand,
                          hint: 'Contraseña',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: brand.textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
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
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: brand.accent,
                          foregroundColor: brand.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BrandConfig brand, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: brand.textSecondary),
      prefixIcon: Icon(icon, color: brand.textSecondary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: brand.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brand.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brand.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brand.accent),
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
