import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../branding/brand.dart';

/// Ids válidos del catálogo — los mismos que genera
/// scripts/generate-coach-avatars.mjs en el B2B.
const coachAvatarIds = <String>[
  'bronce',
  'tide',
  'ember',
  'slate',
  'vine',
  'iron',
  'rosa',
  'terra',
  'amber',
  'onyx',
  'cielo',
  'lima',
];

/// Avatar ilustrado del coach — SVG local, sin red ni fotos subidas.
/// `avatar` es el id elegido al crear el coach en el B2B; sin él se
/// muestran las iniciales. `borderRadius` nulo = círculo.
class CoachAvatar extends StatelessWidget {
  const CoachAvatar({
    super.key,
    this.avatar,
    required this.initials,
    this.size = 48,
    this.height,
    this.borderRadius,
  });

  final String? avatar;
  final String initials;
  final double size;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final id = avatar;
    final valid = id != null && coachAvatarIds.contains(id);
    if (!valid) {
      return Container(
        width: size,
        height: height ?? size,
        decoration: BoxDecoration(
          shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
          color: brand.surface,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: size * 0.33,
              fontWeight: FontWeight.w900,
              color: brand.accent,
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(999),
      child: SizedBox(
        width: size,
        height: height ?? size,
        child: SvgPicture.asset(
          'assets/avatars/coaches/$id.svg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
