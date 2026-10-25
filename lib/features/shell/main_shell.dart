import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/config/app_config.dart';
import '../../core/firebase/push_notification_service.dart';
import '../../core/utils/haptics.dart';
import '../../data/repositories/gym_repositories.dart';
import '../allies/allies_screen.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../promotions/promotions_screen.dart';
import '../rewards/rewards_screen.dart';
import '../support/support_chat_screen.dart';
import 'bottom_nav_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  StreamSubscription<int>? _tabSub;
  StreamSubscription<void>? _supportSub;
  StreamSubscription<void>? _rewardsSub;
  int _prevIndex = 0;

  late final AnimationController _tabFadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: 1.0,
  );

  static const _screens = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    AlliesScreen(),
    PromotionsScreen(),
    RewardsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (AppConfig.firebaseActive) {
      /// Tap en notificación → tab destino (SPONSOR → Aliados, BRAND →
      /// Descuentos). El cold start llega antes del primer frame — se
      /// consume una vez aquí.
      _tabSub = PushNotificationService.tabRequests.listen(_goToTab);
      _supportSub = PushNotificationService.supportRequests.listen(
        (_) => _openSupport(),
      );
      _rewardsSub = PushNotificationService.rewardsRequests.listen(
        (_) => _openRewards(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final initial = PushNotificationService.takeInitialTab();
        if (initial != null) _goToTab(initial);
        if (PushNotificationService.takeInitialSupport()) _openSupport();
        if (PushNotificationService.takeInitialRewards()) _openRewards();
      });
    }
  }

  void _goToTab(int index) {
    ref.read(bottomNavIndexProvider.notifier).go(index);
  }

  /// Push/tap de soporte → abre el chat encima del shell actual.
  void _openSupport() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SupportChatScreen()));
  }

  /// Push de lealtad (meta cumplida) → abre Recompensas.
  void _openRewards() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RewardsScreen(embedded: false)),
    );
  }

  @override
  void dispose() {
    _tabSub?.cancel();
    _supportSub?.cancel();
    _rewardsSub?.cancel();
    _tabFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Topics FCM por sede/estatus — se re-suscribe si el socio cambia.
    if (AppConfig.firebaseActive) {
      ref.listen(memberProvider, (prev, next) {
        if (next.hasValue) {
          PushNotificationService.syncTopics(next.value, previous: prev?.value);
        }
      });
    }
    final index = ref.watch(bottomNavIndexProvider);
    if (index != _prevIndex) {
      _prevIndex = index;
      _tabFadeController.forward(from: 0.0);
    }

    /// extendBody remueve el MediaQuery padding del body (notch incluido).
    /// Lo restauramos y envolvemos en SafeArea: los ListView de las
    /// pantallas traen padding explícito y no consumen el inset solos.
    /// El inferior queda en 0: la barra lo cubre.
    final padding = MediaQuery.of(context).padding;
    final curved = CurvedAnimation(
      parent: _tabFadeController,
      curve: Curves.easeOutCubic,
    );

    return Scaffold(
      extendBody: true,
      body: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: padding.copyWith(bottom: 0)),
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.35, end: 1.0).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(curved),
              child: IndexedStack(index: index, children: _screens),
            ),
          ),
        ),
      ),
      bottomNavigationBar: MainBottomBar(
        index: index,
        onChanged: (newIdx) {
          if (newIdx != index) {
            AppHaptics.selection();
            ref.read(bottomNavIndexProvider.notifier).go(newIdx);
          } else {
            AppHaptics.light();
          }
        },
      ),
    );
  }
}

class MainBottomBar extends StatelessWidget {
  const MainBottomBar({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    /// SafeArea va DENTRO del Container: el color de fondo llega hasta
    /// el borde inferior de la pantalla (cubre el home indicator).
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: brand.surface.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: brand.cardBorder),
              left: BorderSide(color: brand.cardBorder),
              right: BorderSide(color: brand.cardBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 32,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 66,
              child: Row(
                children: [
                  Expanded(
                    child: _BarItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Inicio',
                      selected: index == 0,
                      onTap: () => onChanged(0),
                    ),
                  ),
                  Expanded(
                    child: _BarItem(
                      icon: Icons.calendar_month_outlined,
                      activeIcon: Icons.calendar_month_rounded,
                      label: 'Explorar',
                      selected: index == 1,
                      onTap: () => onChanged(1),
                    ),
                  ),
                  Expanded(
                    child: _BarItem(
                      icon: Icons.handshake_outlined,
                      activeIcon: Icons.handshake_rounded,
                      label: 'Aliados',
                      selected: index == 2,
                      onTap: () => onChanged(2),
                    ),
                  ),
                  Expanded(
                    child: _BarItem(
                      icon: Icons.local_activity_outlined,
                      activeIcon: Icons.local_activity_rounded,
                      label: 'Promos',
                      selected: index == 3,
                      onTap: () => onChanged(3),
                    ),
                  ),
                  Expanded(
                    child: _BarItem(
                      icon: Icons.emoji_events_outlined,
                      activeIcon: Icons.emoji_events_rounded,
                      label: 'Premios',
                      selected: index == 4,
                      onTap: () => onChanged(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatefulWidget {
  const _BarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<_BarItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final selected = widget.selected;
    final color = selected ? brand.accent : brand.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 28,
              child: Center(
                child: AnimatedScale(
                  scale: selected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    selected ? widget.activeIcon : widget.icon,
                    size: 24,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? brand.textPrimary : brand.textSecondary,
                letterSpacing: selected ? 0.2 : 0,
              ),
            ),
            const SizedBox(height: 4),
            // Punto luminoso estilo Spotify bajo la pestaña activa
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: selected ? 14 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? brand.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: brand.accent.withValues(alpha: 0.65),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
