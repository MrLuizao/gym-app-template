import 'package:flutter/material.dart';

import '../branding/brand.dart';
import 'pressable_scale.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.radius = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? brand.cardBorder),
    );
    final card = Material(
      color: color ?? brand.surface,
      clipBehavior: Clip.antiAlias,
      shape: shape,
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.975,
      child: card,
    );
  }
}
