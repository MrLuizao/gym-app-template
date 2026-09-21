import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/app_card.dart';

class GoalProgressSection extends StatelessWidget {
  const GoalProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Progreso de Meta',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver detalles'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 190,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(double.infinity, 190),
                      painter: _GaugePainter(
                        progress: 0.55,
                        activeColor: brand.accent,
                        inactiveColor:
                            brand.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '76.5kg',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: -0.8,
                              color: brand.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Peso actual',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: brand.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  _GaugeStat(label: 'Peso perdido', value: '8.5', unit: 'kg'),
                  _GaugeStat(label: 'Calorías', value: '6.4K', unit: 'kcal'),
                  _GaugeStat(label: 'Retos', value: '3', unit: 'retos'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    const segmentCount = 20;
    const startAngle = 160 * math.pi / 180;
    const sweep = 220 * math.pi / 180;

    final radius = (size.width / 2 - 24).clamp(70.0, 150.0);
    final center = Offset(size.width / 2, size.height * 0.78);
    const segmentWidth = 9.0;
    const segmentLength = 26.0;

    for (var i = 0; i < segmentCount; i++) {
      final t = i / (segmentCount - 1);
      final angle = startAngle + t * sweep;
      final filled = t <= progress;
      final paint = Paint()
        ..color = filled ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            radius - segmentLength,
            -segmentWidth / 2,
            segmentLength,
            segmentWidth,
          ),
          const Radius.circular(6),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.inactiveColor != inactiveColor;
}

class _GaugeStat extends StatelessWidget {
  const _GaugeStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: brand.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: brand.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
