import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app.dart';
import '../branding/brand.dart';
import '../config/app_config.dart';
import '../../features/shell/main_shell.dart';

/// Transición de éxito tras login/registro — un punto accent pulsa en
/// el centro, se expande a un halo y el wordmark de la marca aparece;
/// al terminar reemplaza todo por el gate (referencia: outro glacio).
class AuthSuccessScreen extends StatefulWidget {
  const AuthSuccessScreen({super.key});

  static Future<void> play(BuildContext context) =>
      playOn(Navigator.of(context));

  /// Versión que acepta el NavigatorState directo — el llamador puede
  /// capturarlo antes de un posible unmount (el gate reemplaza la
  /// pantalla de login en cuanto el stream de auth emite).
  static Future<void> playOn(NavigatorState nav) {
    return nav.push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => const AuthSuccessScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen> {
  static const _indigo = Color(0xFF6D5DF1);
  static const _violet = Color(0xFF8B5CF6);
  static const _pink = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (mounted) HapticFeedback.heavyImpact();
    });
    Future<void>.delayed(const Duration(milliseconds: 1200), _finish);
  }

  void _finish() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            AppConfig.firebaseActive ? const AuthGate() : const MainShell(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      backgroundColor: brand.background,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _indigo.withValues(alpha: 0.26),
                        _violet.withValues(alpha: 0.12),
                        _pink.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.88, 0.88),
                  end: const Offset(1.14, 1.14),
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
            Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'RIR',
                      style: TextStyle(
                        fontSize: 42,
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
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                      child: const Text(
                        'HUB',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .scale(
                  begin: const Offset(0.82, 0.82),
                  end: const Offset(1, 1),
                  duration: 480.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
