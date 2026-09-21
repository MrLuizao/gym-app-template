import 'package:flutter/material.dart';

import '../branding/brand.dart';

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(icon, size: 20, color: brand.textPrimary),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: brand.accent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: brand.background, width: 1.5),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: brand.background,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
