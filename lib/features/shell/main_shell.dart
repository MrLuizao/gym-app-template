import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/config/app_config.dart';
import '../../core/firebase/push_notification_service.dart';
import '../../data/repositories/gym_repositories.dart';
import '../allies/allies_screen.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../promotions/promotions_screen.dart';
import 'bottom_nav_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Topics FCM por sede/estatus — se re-suscribe si el socio cambia.
    if (AppConfig.firebaseActive) {
      ref.listen(memberProvider, (prev, next) {
        if (next.hasValue) {
          PushNotificationService.syncTopics(next.value, previous: prev?.value);
        }
      });
    }
    final index = ref.watch(bottomNavIndexProvider);
    /// extendBody remueve el MediaQuery padding del body (notch incluido).
    /// Lo restauramos y envolvemos en SafeArea: los ListView de las
    /// pantallas traen padding explícito y no consumen el inset solos.
    /// El inferior queda en 0: la barra lo cubre.
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      extendBody: true,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: padding.copyWith(bottom: 0),
        ),
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: index,
            children: const [
              HomeScreen(),
              ExploreScreen(),
              AlliesScreen(),
              PromotionsScreen(),
              ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottomBar(
        index: index,
        onChanged: ref.read(bottomNavIndexProvider.notifier).go,
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
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: brand.cardBorder),
          left: BorderSide(color: brand.cardBorder),
          right: BorderSide(color: brand.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _BarItem(
                  icon: Icons.home_outlined,
                  label: 'Inicio',
                  selected: index == 0,
                  onTap: () => onChanged(0),
                ),
              ),
              Expanded(
                child: _BarItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Explorar',
                  selected: index == 1,
                  onTap: () => onChanged(1),
                ),
              ),
              Expanded(
                child: _BarItem(
                  icon: Icons.handshake_outlined,
                  label: 'Aliados',
                  selected: index == 2,
                  onTap: () => onChanged(2),
                ),
              ),
              Expanded(
                child: _BarItem(
                  icon: Icons.local_activity_outlined,
                  label: 'Descuentos',
                  selected: index == 3,
                  onTap: () => onChanged(3),
                ),
              ),
              Expanded(
                child: _BarItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Perfil',
                  selected: index == 4,
                  onTap: () => onChanged(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final color = selected ? brand.accent : brand.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
            child: Center(child: Icon(icon, size: 24, color: color)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
