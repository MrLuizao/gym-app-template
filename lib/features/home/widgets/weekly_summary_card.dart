import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/app_card.dart';

class WeeklySummarySection extends StatelessWidget {
  const WeeklySummarySection({super.key});

  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Expanded(
        //       child: Text('Resumen Semanal',
        //           style: Theme.of(context).textTheme.titleLarge),
        //     ),
        //     TextButton(
        //       onPressed: () {},
        //       child: const Text('Ver detalles'),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Racha semanal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: brand.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '1.2K',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: brand.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' kcal',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _DayPill(
                        label: _dayLabels[i],
                        number: monday.add(Duration(days: i)).day,
                        active: i == now.weekday - 1,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.number,
    required this.active,
  });

  final String label;
  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(
        color: active ? brand.accent : brand.background,
        borderRadius: BorderRadius.circular(20),
        border: active ? null : Border.all(color: brand.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? brand.background : brand.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.white : brand.surface,
              border: active ? null : Border.all(color: brand.cardBorder),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: active ? brand.background : brand.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
