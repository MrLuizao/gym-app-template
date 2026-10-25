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
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) HapticFeedback.heavyImpact();
    });
    Future<void>.delayed(const Duration(milliseconds: 1700), _finish);
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brand.accent,
                    boxShadow: [
                      BoxShadow(
                        color: brand.accent.withValues(alpha: 0.55),
                        blurRadius: 42,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.2, 0.2),
                  end: const Offset(1, 1),
                  duration: 380.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.35, 1.35),
                  duration: 260.ms,
                  curve: Curves.easeInOut,
                )
                .scale(
                  begin: const Offset(1.35, 1.35),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 30),
            Text(
                  brand.appName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.5,
                    color: brand.textPrimary,
                  ),
                )
                .animate(delay: 650.ms)
                .fadeIn(duration: 420.ms, curve: Curves.easeOut)
                .slideY(
                  begin: 0.35,
                  end: 0,
                  duration: 420.ms,
                  curve: Curves.easeOutCubic,
                ),
          ],
        ),
      ),
    );
  }
}
