import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/branding/brands.dart';
import 'core/theme/app_theme.dart';
import 'data/models/branch.dart';
import 'data/models/trainer.dart';
import 'features/branch_detail/branch_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/payments/checkout_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/trainers/trainer_profile_screen.dart';

class MembersApp extends StatelessWidget {
  const MembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Members',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromBrand(capitalFitness),
      home: const RootGate(),
      onGenerateRoute: (settings) {
        final routeBuilder = _routes[settings.name];
        if (routeBuilder == null) return null;
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 260),
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

  static final Map<String, Widget Function(Object? arguments)> _routes = {
    BranchDetailScreen.routeName: (arguments) =>
        BranchDetailScreen(branch: arguments! as Branch),
    TrainerProfileScreen.routeName: (arguments) =>
        TrainerProfileScreen(trainer: arguments! as Trainer),
    MembershipCheckoutScreen.routeName: (arguments) =>
        const MembershipCheckoutScreen(),
  };
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _loadFlag();
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
    if (done == null || size.width < 2 || size.height < 2) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return done ? const MainShell() : const OnboardingScreen();
  }
}
