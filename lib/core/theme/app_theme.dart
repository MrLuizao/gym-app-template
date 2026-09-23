import 'package:flutter/material.dart';

import '../branding/brand.dart';

class AppTheme {
  AppTheme._();

  static ThemeData fromBrand(BrandConfig brand) {
    final colorScheme = ColorScheme.dark(
      primary: brand.accent,
      secondary: brand.accent,
      surface: brand.surface,
      onSurface: brand.textPrimary,
      error: brand.occupancyHigh,
    );

    TextStyle style(
      double size,
      FontWeight weight,
      Color color, {
      double letterSpacing = 0,
      double height = 1.2,
    }) => TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

    final textTheme = TextTheme(
      displaySmall: style(
        34,
        FontWeight.w900,
        brand.textPrimary,
        letterSpacing: -1,
      ),
      headlineMedium: style(
        26,
        FontWeight.w900,
        brand.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineSmall: style(
        21,
        FontWeight.w900,
        brand.textPrimary,
        letterSpacing: -0.3,
      ),
      titleLarge: style(17, FontWeight.w900, brand.textPrimary),
      titleMedium: style(14, FontWeight.w900, brand.textPrimary),
      bodyLarge: style(15, FontWeight.w600, brand.textPrimary),
      bodyMedium: style(13, FontWeight.w500, brand.textSecondary, height: 1.35),
      bodySmall: style(11, FontWeight.w600, brand.textSecondary),
      labelLarge: style(12, FontWeight.w900, brand.textPrimary),
      labelMedium: style(11, FontWeight.w800, brand.textSecondary),
      labelSmall: style(10, FontWeight.w800, brand.textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brand.background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: brand.cardBorder, thickness: 1),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.accent,
          textStyle: style(13, FontWeight.w900, brand.accent),
        ),
      ),
      extensions: [brand],
    );
  }
}
