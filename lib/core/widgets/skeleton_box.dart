import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../branding/brand.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 12,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: brand.surface,
            borderRadius: BorderRadius.circular(radius),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          colors: [brand.surface, brand.cardBorder, brand.surface],
        );
  }
}
