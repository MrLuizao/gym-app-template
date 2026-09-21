import 'package:flutter/material.dart';

import '../branding/brand.dart';

class CapacityRing extends StatelessWidget {
  const CapacityRing({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 6,
    this.showLabel = true,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final target = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: target),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        final color = brand.occupancyFor(animated);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: animated,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: brand.cardBorder,
              ),
              if (showLabel)
                Text(
                  '${(animated * 100).round()}%',
                  style: TextStyle(
                    fontSize: size * 0.24,
                    fontWeight: FontWeight.w900,
                    color: brand.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
