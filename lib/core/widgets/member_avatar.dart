import 'package:flutter/material.dart';

import '../branding/brand.dart';

/// Avatar prediseñado — icono + gradiente, sin imágenes. El socio
/// guarda solo el `id` en `users/{docId}.avatar`.
class AvatarSpec {
  const AvatarSpec(this.id, this.icon, this.colors, {this.iconDark = false});

  final String id;
  final IconData icon;
  final List<Color> colors;

  /// Icono oscuro sobre gradientes claros (amarillos/verdes suaves).
  final bool iconDark;
}

const memberAvatarCatalog = <AvatarSpec>[
  AvatarSpec('volt', Icons.bolt_rounded, [Color(0xFFFDE047), Color(0xFFEAB308)], iconDark: true),
  AvatarSpec('flame', Icons.local_fire_department_rounded, [Color(0xFFFB923C), Color(0xFFDC2626)]),
  AvatarSpec('dumbbell', Icons.fitness_center_rounded, [Color(0xFF38BDF8), Color(0xFF1D4ED8)]),
  AvatarSpec('runner', Icons.directions_run_rounded, [Color(0xFF4ADE80), Color(0xFF15803D)], iconDark: true),
  AvatarSpec('heart', Icons.favorite_rounded, [Color(0xFFF472B6), Color(0xFFBE185D)]),
  AvatarSpec('trophy', Icons.emoji_events_rounded, [Color(0xFFFACC15), Color(0xFFA16207)], iconDark: true),
  AvatarSpec('rocket', Icons.rocket_launch_rounded, [Color(0xFFA78BFA), Color(0xFF6D28D9)]),
  AvatarSpec('shield', Icons.shield_rounded, [Color(0xFF94A3B8), Color(0xFF334155)]),
  AvatarSpec('star', Icons.star_rounded, [Color(0xFFFDBA74), Color(0xFFEA580C)]),
  AvatarSpec('timer', Icons.timer_rounded, [Color(0xFF2DD4BF), Color(0xFF0F766E)], iconDark: true),
  AvatarSpec('zen', Icons.self_improvement_rounded, [Color(0xFFF0ABFC), Color(0xFFA21CAF)]),
  AvatarSpec('waves', Icons.water_rounded, [Color(0xFF67E8F9), Color(0xFF0E7490)]),
];

AvatarSpec? avatarSpecFor(String? id) {
  if (id == null) return null;
  for (final spec in memberAvatarCatalog) {
    if (spec.id == id) return spec;
  }
  return null;
}

/// Avatar del socio: gradiente + icono si eligió uno, si no las
/// iniciales (estilo anterior). `borderRadius` nulo = círculo.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    this.avatarId,
    required this.initials,
    this.size = 48,
    this.height,
    this.borderRadius,
  });

  final String? avatarId;
  final String initials;
  final double size;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final spec = avatarSpecFor(avatarId);
    if (spec == null) {
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
    return Container(
      width: size,
      height: height ?? size,
      decoration: BoxDecoration(
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: spec.colors,
        ),
      ),
      child: Center(
        child: Icon(
          spec.icon,
          size: size * 0.52,
          color: spec.iconDark ? const Color(0xFF1C1917) : Colors.white,
        ),
      ),
    );
  }
}
