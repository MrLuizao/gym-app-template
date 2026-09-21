import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/branding/brand.dart';
import '../shell/main_shell.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
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
                  _SocialButton(
                    label: 'Continuar con Google',
                    icon: Icons.g_mobiledata_rounded,
                    iconColor: const Color(0xFF4285F4),
                    filled: true,
                    onTap: () => _continue(context),
                  ),
                  const SizedBox(height: 14),
                  _SocialButton(
                    label: 'Continuar con Apple',
                    icon: Icons.apple_rounded,
                    iconColor: brand.textPrimary,
                    filled: false,
                    onTap: () => _continue(context),
                  ),
                  const SizedBox(height: 28),
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
