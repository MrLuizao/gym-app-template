import 'package:flutter/material.dart';

import '../branding/brand.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    this.url,
    this.icon = Icons.fitness_center_rounded,
  });

  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand.surface, brand.background],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 40, color: brand.cardBorder),
      ),
    );
    final url = this.url;
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (_, _, _) => fallback,
      frameBuilder: (context, child, frame, wasSync) =>
          frame == null ? fallback : child,
    );
  }
}
