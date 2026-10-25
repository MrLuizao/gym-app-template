import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/branding/brand.dart';
import 'core/branding/brands.dart';
import 'core/config/app_config.dart';
import 'core/firebase/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/haptics.dart';
import 'data/models/branch.dart';
import 'data/models/sponsor_ad.dart';
import 'data/models/trainer.dart';
import 'data/repositories/gym_repositories.dart';
import 'features/auth/claim_member_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/branch_detail/branch_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/payments/checkout_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/sponsor_detail/sponsor_detail_screen.dart';
import 'features/trainers/trainer_profile_screen.dart';

class MembersApp extends StatelessWidget {
  const MembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Members',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromBrand(rirHub),
      home: const RootGate(),
      onGenerateRoute: (settings) {
        final routeBuilder = _routes[settings.name];
        if (routeBuilder == null) return null;
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 360),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, animation, _) => routeBuilder(settings.arguments),
          transitionsBuilder: (_, animation, _, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.035),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  static Map<String, Widget Function(Object? arguments)> get _routes => {
    BranchDetailScreen.routeName: (arguments) =>
        BranchDetailScreen(branch: arguments! as Branch),
    TrainerProfileScreen.routeName: (arguments) =>
        TrainerProfileScreen(trainer: arguments! as Trainer),
    MembershipCheckoutScreen.routeName: (arguments) =>
        const MembershipCheckoutScreen(),
    SponsorDetailScreen.routeName: (arguments) =>
        SponsorDetailScreen(ad: arguments! as SponsorAd),
  };
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool? _onboardingDone;
  bool _splashCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadFlag();
    Future<void>.delayed(const Duration(milliseconds: 720), () {
      if (!mounted) return;
      AppHaptics.light();
      setState(() => _splashCompleted = true);
    });
  }

  Future<void> _loadFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _onboardingDone = prefs.getBool('onboarding_done') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final done = _onboardingDone;
    final size = MediaQuery.sizeOf(context);
    if (size.width < 2 || size.height < 2) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final showSplash = done == null || !_splashCompleted;
    final signedIn =
        AppConfig.firebaseActive && FirebaseAuth.instance.currentUser != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 460),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: showSplash
          ? const _LuxurySplashView(key: ValueKey('splash'))
          : ((done || signedIn)
                ? const AuthGate(key: ValueKey('auth_gate'))
                : const OnboardingScreen(key: ValueKey('onboarding'))),
    );
  }
}

/// Splash reveal estilo Spotify: emblema que respira sobre halo radial.
class _LuxurySplashView extends StatelessWidget {
  const _LuxurySplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      backgroundColor: brand.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  brand.accent.withValues(alpha: 0.24),
                  brand.accent.withValues(alpha: 0),
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.15, 1.15),
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: brand.accent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: brand.accent.withValues(alpha: 0.45),
                      blurRadius: 36,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: brand.readableOn(brand.accent),
                  size: 34,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.65, 0.65),
                    end: const Offset(1, 1),
                    duration: 480.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 280.ms),
              const SizedBox(height: 20),
              Text(
                brand.appName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.2,
                  color: brand.textPrimary,
                ),
              )
                  .animate(delay: 140.ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
            ],
          ),
        ],
      ),
    );
  }
}

/// Error visible del gate — antes los errores rebotaban al login
/// sin decir por qué; ahora se ve el fallo real (permisos, red, etc.).
class _GateError extends StatelessWidget {
  const _GateError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No se pudo cargar tu sesión:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Con Firebase: la sesión decide si se ve login o la app.
/// Sin Firebase (demo): directo a MainShell.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.firebaseActive) return const MainShell();
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () => const _LuxurySplashView(),
      error: (e, _) => _GateError(error: e),
      data: (user) {
        if (user == null) return const LoginScreen();

        /// Login social OK pero sin doc de socio → reclamar el
        /// número que le dieron en recepción.
        return ref
            .watch(memberDocExistsProvider)
            .when(
              loading: () => const _LuxurySplashView(),
              error: (e, _) => _GateError(error: e),
              data: (exists) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                switchInCurve: Curves.easeOutCubic,
                child: exists
                    ? const MainShell(key: ValueKey('main_shell'))
                    : const ClaimMemberScreen(key: ValueKey('claim_member')),
              ),
            );
      },
    );
  }
}
