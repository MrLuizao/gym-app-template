import 'package:flutter/material.dart';

import '../branding/brand.dart';

/// Gráfica de pronóstico de aforo por hora (6:00 → 22:00).
///
/// La hora actual usa [currentRatio] (dato en vivo) y se pinta en acento.
/// [drift] permite variar la curva por sede (ej. `branch.id.hashCode % 9 - 4`).
class HourlyForecastChart extends StatelessWidget {
  const HourlyForecastChart({
    super.key,
    required this.currentRatio,
    this.drift = 0,
  });

  final double currentRatio;
  final double drift;

  static const _curve = {
    6: 0.30, 7: 0.55, 8: 0.78, 9: 0.70, 10: 0.48, 11: 0.38,
    12: 0.45, 13: 0.40, 14: 0.34, 15: 0.42, 16: 0.55, 17: 0.72,
    18: 0.86, 19: 0.95, 20: 0.88, 21: 0.65, 22: 0.42,
  };

  double forecastFor(int hour, int now) {
    if (hour == now) return currentRatio;
    return ((_curve[hour] ?? 0.3) + drift).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final now = DateTime.now().hour;
    final hours = List.generate(17, (i) => i + 6);
    return Column(
      children: [
        SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final hour in hours)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor:
                          forecastFor(hour, now).clamp(0.08, 1.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: hour == now
                              ? brand.accent
                              : brand
                                  .occupancyFor(forecastFor(hour, now))
                                  .withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          border: hour == now
                              ? Border.all(color: brand.accent, width: 1.5)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final hour in hours)
              Expanded(
                child: Text(
                  hour.isEven ? '$hour' : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color:
                        hour == now ? brand.accent : brand.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ForecastLegend extends StatelessWidget {
  const ForecastLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Row(
      children: [
        _ForecastDot(color: brand.accent, label: 'AHORA'),
        const SizedBox(width: 14),
        _ForecastDot(color: brand.occupancyLow, label: 'Baja'),
        const SizedBox(width: 14),
        _ForecastDot(color: brand.occupancyMedium, label: 'Media'),
        const SizedBox(width: 14),
        _ForecastDot(color: brand.occupancyHigh, label: 'Alta'),
      ],
    );
  }
}

class _ForecastDot extends StatelessWidget {
  const _ForecastDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: brand.textSecondary,
          ),
        ),
      ],
    );
  }
}
