import 'package:flutter/material.dart';

import '../branding/brand.dart';
import 'pressable_scale.dart';

/// CTA principal que al cargar morfa su contenido a un loader circular
/// centrado — la píldora conserva su forma y el label se desvanece
/// mientras aparece un aro girando (referencia: transición glacio).
class MorphLoadingButton extends StatelessWidget {
  const MorphLoadingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PressableScale(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [brand.accent, brand.accentDark],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          child: loading
              ? Center(
                  key: const ValueKey('loading'),
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: brand.background,
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: brand.background),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: brand.background,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
