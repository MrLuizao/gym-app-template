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
import '../../core/firebase/auth_provider.dart';
import '../../core/firebase/google_sign_in_button_stub.dart'
    if (dart.library.js_interop) '../../core/firebase/google_sign_in_button_web.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/auth_success_screen.dart';
import '../../core/widgets/pressable_scale.dart';

/// Login del socio — registro self-service con Google/Apple.
/// El doc /users/{uid} en Firestore define membresía, sede y número;
/// si no existe, el gate manda a completar perfil.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _indigo = Color(0xFF6D5DF1);
  static const _violet = Color(0xFF8B5CF6);
  static const _pink = Color(0xFFEC4899);

  bool _loading = false;
  String? _error;

  /// Navigator raíz capturado temprano — el AuthGate puede desmontar
  /// esta pantalla en cuanto el stream emite la sesión, y el reveal
  /// de éxito debe correr aunque el widget ya no esté montado.
  late final NavigatorState _nav;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nav = Navigator.of(context);
  }

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

  /// La transición de éxito corre sobre el Navigator raíz — esta
  /// pantalla puede estar desmontada si el gate ya la reemplazó.
  Future<void> _afterSignIn() async {
    if (_nav.mounted) {
      if (_nav.canPop()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_done', true);
      }
      await AuthSuccessScreen.playOn(_nav);
    }
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
                    _indigo.withValues(alpha: 0.26),
                    _violet.withValues(alpha: 0.08),
                    Colors.transparent,
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
                    _pink.withValues(alpha: 0.28),
                    _violet.withValues(alpha: 0.08),
                    Colors.transparent,
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
                      child: Stack(
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
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          )
                          .fadeIn(duration: 320.ms),
                    ),
                    const SizedBox(height: 22),
                    Text(
                          'ENTRENA.\nRESERVA.\nREPITE.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: brand.textPrimary,
                                fontWeight: FontWeight.w900,
                                height: 1.02,
                                letterSpacing: -1,
                              ),
                        )
                        .animate(delay: 220.ms)
                        .fadeIn(duration: 420.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 14),
                    Text(
                      brand.tagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: brand.textSecondary,
                      ),
                    ).animate(delay: 340.ms).fadeIn(duration: 380.ms),
                    const SizedBox(height: 40),

                    /// Un botón por plataforma: web exige el oficial de
                    /// Google (FedCM); iOS → Apple; Android → Google.
                    if (kIsWeb)
                      Center(child: googleSignInWebButton())
                    else if (Platform.isIOS)
                      _SocialButton(
                            label: 'Continuar con Apple',
                            icon: Icons.apple_rounded,
                            loading: _loading,
                            onTap: () => _socialSignIn(
                              () => ref
                                  .read(authControllerProvider)
                                  .signInWithApple(),
                              'Apple',
                            ),
                          )
                          .animate(delay: 460.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                    else
                      _SocialButton(
                            label: 'Continuar con Google',
                            icon: Icons.g_mobiledata_rounded,
                            loading: _loading,
                            onTap: () => _socialSignIn(
                              () => ref
                                  .read(authControllerProvider)
                                  .signInWithGoogle(),
                              'Google',
                            ),
                          )
                          .animate(delay: 460.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
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
                    ).animate(delay: 560.ms).fadeIn(duration: 380.ms),
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
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      enableHaptic: false,
      onTap: loading
          ? null
          : () {
              AppHaptics.medium();
              onTap();
            },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: brand.cardBorder),
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
                      color: brand.accent,
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: brand.textPrimary),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        color: brand.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
