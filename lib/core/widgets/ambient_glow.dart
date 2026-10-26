import 'package:flutter/material.dart';

import '../branding/brand.dart';

/// Destello ambiental inmersivo en degradado con los colores oficiales de RIRHUB
/// (#6D5DF1 índigo -> #8B5CF6 violeta -> #EC4899 rosa).
class AmbientTopGlow extends StatelessWidget {
  const AmbientTopGlow({
    super.key,
    this.height = 320,
    this.top = -90,
    this.left = -60,
    this.right = -60,
  });

  final double height;
  final double top;
  final double left;
  final double right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      height: height,
      child: IgnorePointer(
        child: Stack(
          children: [
            // Destello índigo/violeta a la izquierda
            Positioned(
              left: -20,
              top: 0,
              child: Container(
                width: 320,
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BrandConfig.logoIndigo.withValues(alpha: 0.28),
                      BrandConfig.logoViolet.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Destello violeta/rosa a la derecha
            Positioned(
              right: -20,
              top: 0,
              child: Container(
                width: 320,
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BrandConfig.logoPink.withValues(alpha: 0.24),
                      BrandConfig.logoViolet.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
