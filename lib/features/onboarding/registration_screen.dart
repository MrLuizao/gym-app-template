import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/branding/brand.dart';
import '../../core/config/app_config.dart';
import '../../core/firebase/auth_provider.dart';
import '../../core/firebase/google_sign_in_button_stub.dart'
    if (dart.library.js_interop) '../../core/firebase/google_sign_in_button_web.dart';
import '../../core/widgets/auth_success_screen.dart';
import '../auth/login_screen.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _indigo = Color(0xFF6D5DF1);
  static const _violet = Color(0xFF8B5CF6);
  static const _pink = Color(0xFFEC4899);

  /// Proveedor en vuelo ('google' | 'apple' | null) — solo ese botón
  /// morfa a loader; el otro se atenúa.
  String? _loadingProvider;
  String? _error;

  /// Navigator raíz — sobrevive aunque el gate desmonte esta pantalla.
  late final NavigatorState _nav;

  bool get _loading => _loadingProvider != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nav = Navigator.of(context);
  }

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!_nav.mounted) return;
    await AuthSuccessScreen.playOn(_nav);
  }

  /// Sign-in social real — al éxito el AuthGate decide entre
  /// completar perfil (sin /users/{uid}) o entrar al shell.
  Future<void> _social(
    Future<void> Function() signIn,
    String provider,
    String providerKey,
  ) async {
    if (_loading) return;
    setState(() {
      _loadingProvider = providerKey;
      _error = null;
    });
    try {
      await signIn();
      if (mounted) await _finish(context);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        setState(
          () => _error = 'No se pudo continuar con $provider (${e.code.name})',
        );
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        setState(() => _error = 'No se pudo continuar con $provider');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = 'No se pudo continuar (${e.code})');
    } catch (e) {
      setState(() => _error = 'No se pudo continuar con $provider ($e)');
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final firebase = AppConfig.firebaseActive;

    /// En web el botón GIS completa el sign-in sin callback — cuando
    /// llega la sesión por authState entramos directo al gate.
    ref.listen(authStateProvider, (_, next) {
      if (next.value != null && mounted) _finish(context);
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
                    _indigo.withValues(alpha: 0.28),
                    _violet.withValues(alpha: 0.08),
                    Colors.transparent,
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
                    _pink.withValues(alpha: 0.28),
                    _violet.withValues(alpha: 0.08),
                    Colors.transparent,
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
                  Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: RadialGradient(
                                colors: [
                                  _indigo.withValues(alpha: 0.28),
                                  _pink.withValues(alpha: 0.10),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'RIR',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [_indigo, _violet, _pink],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(
                                      Rect.fromLTWH(
                                        0,
                                        0,
                                        bounds.width,
                                        bounds.height,
                                      ),
                                    ),
                                child: const Text(
                                  'HUB',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.2,
                                    height: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0.82, 0.82),
                        end: const Offset(1, 1),
                        duration: 520.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 22),
                  Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: brand.textPrimary,
                        ),
                      )
                      .animate(delay: 130.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 8),
                  Text(
                    'Únete a RIRHUB y entrena sin límites',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: brand.textSecondary,
                    ),
                  ).animate(delay: 240.ms).fadeIn(duration: 340.ms),
                  const SizedBox(height: 44),

                  /// En web Google exige su botón oficial (FedCM);
                  /// el evento llega por authenticationEvents.
                  if (kIsWeb)
                    Center(child: googleSignInWebButton())
                  else
                    _SocialButton(
                          label: 'Continuar con Google',
                          icon: Icons.g_mobiledata_rounded,
                          iconColor: const Color(0xFF4285F4),
                          filled: true,
                          loading: _loadingProvider == 'google',
                          dimmed: _loadingProvider == 'apple',
                          onTap: () => _social(
                            () => ref
                                .read(authControllerProvider)
                                .signInWithGoogle(),
                            'Google',
                            'google',
                          ),
                        )
                        .animate(delay: 380.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                  const SizedBox(height: 14),
                  if (!kIsWeb && Platform.isIOS)
                    _SocialButton(
                          label: 'Continuar con Apple',
                          icon: Icons.apple_rounded,
                          iconColor: brand.textPrimary,
                          filled: false,
                          loading: _loadingProvider == 'apple',
                          dimmed: _loadingProvider == 'google',
                          onTap: () => _social(
                            () => ref
                                .read(authControllerProvider)
                                .signInWithApple(),
                            'Apple',
                            'apple',
                          ),
                        )
                        .animate(delay: 480.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
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
                    ).animate(delay: 580.ms).fadeIn(duration: 320.ms)
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
                    ).animate(delay: 580.ms).fadeIn(duration: 320.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Al continuar aceptas los Términos y Condiciones\ny la Política de Privacidad de RIRHUB.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: brand.textSecondary,
                    ),
                  ).animate(delay: 660.ms).fadeIn(duration: 320.ms),
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
    this.loading = false,
    this.dimmed = false,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool filled;
  final VoidCallback onTap;
  final bool loading;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: dimmed ? 0.45 : 1,
      child: GestureDetector(
        onTap: (loading || dimmed) ? null : onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: filled
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: loading
                ? Center(
                    key: const ValueKey('loading'),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: filled ? Colors.black : brand.accent,
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('label'),
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
        ),
      ),
    );
  }
}
