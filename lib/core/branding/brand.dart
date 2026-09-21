import 'package:flutter/material.dart';

@immutable
class BrandConfig extends ThemeExtension<BrandConfig> {
  const BrandConfig({
    required this.id,
    required this.appName,
    required this.tagline,
    required this.background,
    required this.surface,
    required this.cardBorder,
    required this.accent,
    this.accentDark = const Color(0xFF4037C1),
    required this.textPrimary,
    required this.textSecondary,
    this.occupancyLow = const Color(0xFF10B981),
    this.occupancyMedium = const Color(0xFFF59E0B),
    this.occupancyHigh = const Color(0xFFEF4444),
  });

  final String id;
  final String appName;
  final String tagline;
  final Color background;
  final Color surface;
  final Color cardBorder;
  final Color accent;
  final Color accentDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color occupancyLow;
  final Color occupancyMedium;
  final Color occupancyHigh;

  Color occupancyFor(double ratio) {
    if (ratio < 0.5) return occupancyLow;
    if (ratio <= 0.8) return occupancyMedium;
    return occupancyHigh;
  }

  String occupancyLabelFor(double ratio) {
    if (ratio < 0.5) return 'BAJO';
    if (ratio <= 0.8) return 'MEDIO';
    return 'ALTO';
  }

  /// Color del aliado si lo define, o el acento de la marca.
  Color allyAccent(int? brandColor) =>
      brandColor != null ? Color(brandColor) : accent;

  /// Texto legible sobre [bg]: oscuro en fondos claros, blanco en oscuros.
  Color readableOn(Color bg) =>
      bg.computeLuminance() > 0.45 ? background : Colors.white;

  @override
  BrandConfig copyWith() => this;

  @override
  BrandConfig lerp(covariant BrandConfig? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

extension BrandContext on BuildContext {
  BrandConfig get brand => Theme.of(this).extension<BrandConfig>()!;
}
