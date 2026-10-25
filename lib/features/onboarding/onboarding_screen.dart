import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/branding/brand.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/primary_button.dart';
import 'registration_screen.dart';

class _SlideData {
  const _SlideData(this.icon, this.badge, this.title, this.subtitle);

  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
}

const _slides = <_SlideData>[
  _SlideData(
    Icons.speed_rounded,
    'EXPERIENCIA EN VIVO',
    'ENTRENA\nSIN LÍMITES',
    'Aforo en tiempo real, clases grupales y tu pase digital en un solo lugar.',
  ),
  _SlideData(
    Icons.credit_card_rounded,
    'MEMBRESÍA DIGITAL',
    'PAGA DESDE\nLA APP',
    'Renueva tu membresía con tu tarjeta, sin filas ni papeleo.',
  ),
  _SlideData(
    Icons.event_available_rounded,
    'AGENDA INTELIGENTE',
    'RESERVA\nTUS CLASES',
    'Planea tu semana: spinning, funcional, yoga y más con un toque.',
  ),
  _SlideData(
    Icons.local_fire_department_rounded,
    'RACHAS Y PREMIOS',
    'GANA POR\nENTRENAR',
    'Cumple tu meta semanal, mantén tu racha y canjea recompensas exclusivas.',
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
  double _pageOffset = 0;

  late final PageController _pageController = PageController()
    ..addListener(_onScroll);

  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat(reverse: true);

  void _onScroll() {
    if (!mounted || !_pageController.hasClients) return;
    setState(() => _pageOffset = _pageController.page ?? _page.toDouble());
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    AppHaptics.medium();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, _, _) => const RegistrationScreen(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _next() {
    if (_page >= _slides.length - 1) {
      _finish();
      return;
    }
    AppHaptics.selection();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isLast = _page == _slides.length - 1;
    final shift = _pageOffset * 28;

    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        children: [
          // Resplandor ambiental tipo Spotify que reacciona al gesto parallax
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) => Stack(
              children: [
                Positioned(
                  top: -130 + (18 * _floatController.value),
                  right: -90 + shift,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          brand.accent.withValues(alpha: 0.34),
                          brand.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150 - (14 * _floatController.value),
                  left: -110 - (shift * 0.7),
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          brand.accentDark.withValues(alpha: 0.38),
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
                // Barra superior tipo Stories + botón Saltar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            for (var i = 0; i < _slides.length; i++)
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  height: 3.5,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99),
                                    color: i <= _page
                                        ? brand.accent
                                        : Colors.white.withValues(alpha: 0.14),
                                    boxShadow: i == _page
                                        ? [
                                            BoxShadow(
                                              color: brand.accent.withValues(
                                                alpha: 0.55,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PressableScale(
                        onTap: _finish,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
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
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (idx) {
                      if (idx != _page) {
                        AppHaptics.selection();
                        setState(() => _page = idx);
                      }
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      final delta = (index - _pageOffset).clamp(-1.0, 1.0);
                      final scale = 1.0 - (delta.abs() * 0.12);
                      final opacity = 1.0 - (delta.abs() * 0.45);

                      return Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(delta * 24, 0),
                          child: Transform.scale(
                            scale: scale,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Emblema circular con doble halo y borde sutil
                                  Container(
                                    width: 144,
                                    height: 144,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          brand.accent.withValues(alpha: 0.26),
                                          brand.accent.withValues(alpha: 0.04),
                                          brand.accent.withValues(alpha: 0),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: brand.accent.withValues(
                                          alpha: 0.22,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 84,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: brand.surface,
                                          border: Border.all(
                                            color: brand.accent.withValues(
                                              alpha: 0.45,
                                            ),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: brand.accent.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 28,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          slide.icon,
                                          size: 40,
                                          color: brand.accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: brand.accent.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                        color: brand.accent.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      slide.badge,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.6,
                                        color: brand.accent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    slide.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          height: 1.0,
                                          letterSpacing: -1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    slide.subtitle,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: brand.textSecondary,
                                          height: 1.45,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: isLast ? 'COMENZAR AHORA' : 'CONTINUAR',
                          icon: isLast
                              ? Icons.bolt_rounded
                              : Icons.arrow_forward_rounded,
                          onTap: _next,
                        ),
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
