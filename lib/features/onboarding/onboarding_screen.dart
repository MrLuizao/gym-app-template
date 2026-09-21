import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/primary_button.dart';
import 'registration_screen.dart';

class _SlideData {
  const _SlideData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

const _slides = <_SlideData>[
  _SlideData(
    Icons.speed_rounded,
    'ENTRENA\nSIN LÍMITES',
    'Aforo en vivo, clases grupales y tu pase digital en un solo lugar.',
  ),
  _SlideData(
    Icons.credit_card_rounded,
    'PAGA DESDE\nLA APP',
    'Renueva tu membresía con tu tarjeta, sin filas ni papeleo.',
  ),
  _SlideData(
    Icons.event_available_rounded,
    'RESERVA\nTUS CLASES',
    'Planea tu semana: spinning, funcional, yoga y más.',
  ),
  _SlideData(
    Icons.sports_rounded,
    'TUS\nCOACHES',
    'Conoce a los entrenadores de cada sede y sigue a tus favoritos.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _page = 0;

  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RegistrationScreen()),
    );
  }

  void _next() {
    if (_page >= _slides.length - 1) {
      _finish();
      return;
    }
    setState(() => _page += 1);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) => Stack(
              children: [
                Positioned(
                  top: -120 + (16 * _floatController.value),
                  right: -100,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          brand.accent.withValues(alpha: 0.35),
                          brand.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -140 - (12 * _floatController.value),
                  left: -120,
                  child: Container(
                    width: 340,
                    height: 340,
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
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Saltar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: brand.textSecondary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey(_page),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                brand.accent.withValues(alpha: 0.28),
                                brand.accent.withValues(alpha: 0),
                              ],
                            ),
                          ),
                          child: Icon(
                            _slides[_page].icon,
                            size: 56,
                            color: brand.accent,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _slides[_page].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: -0.8,
                            color: brand.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _slides[_page].subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            color: brand.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _slides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: i == _page ? 24 : 7,
                            height: 7,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: i == _page
                                  ? brand.accent
                                  : brand.cardBorder,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: isLast ? 'CREAR MI CUENTA' : 'CONTINUAR',
                      icon: Icons.arrow_forward_rounded,
                      onTap: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
