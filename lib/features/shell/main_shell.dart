import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../checkin/checkin_screen.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../promotions/promotions_screen.dart';
import 'bottom_nav_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          ExploreScreen(),
          CheckInScreen(),
          PromotionsScreen(),
          ProfileScreen(),
        ],
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
    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 22),
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
                  const SizedBox(width: 76),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _ScanButton(
                selected: index == 2,
                onTap: () => onChanged(2),
              ),
            ),
          ),
        ],
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

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlowPress(
          onTap: onTap,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [brand.accent, brand.accentDark],
              ),
              border: Border.all(color: brand.background, width: 4),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 30,
              color: brand.background,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Check-in',
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? brand.accent : brand.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GlowPress extends StatefulWidget {
  const _GlowPress({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_GlowPress> createState() => _GlowPressState();
}

class _GlowPressState extends State<_GlowPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
