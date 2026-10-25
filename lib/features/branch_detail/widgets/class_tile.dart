import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/models/gym_class.dart';

class ClassTile extends StatelessWidget {
  const ClassTile({
    super.key,
    required this.gymClass,
    required this.reserved,
    required this.date,
    this.outOfScope = false,
    this.onTap,
  });

  final GymClass gymClass;
  final bool reserved;

  /// La sede del tile no la cubre el plan del socio (mono-sede) —
  /// reservar aquí siempre falla en el server.
  final bool outOfScope;

  /// Fecha `YYYY-MM-DD` de la ocurrencia mostrada (selector de día).
  final String date;

  /// Abre el sheet de detalle — reservar/cancelar vive ahí, el botón
  /// del tile es solo indicador.
  final VoidCallback? onTap;

  IconData _iconFor(String category) => switch (category) {
    'spinning' => Icons.directions_bike_rounded,
    'yoga' => Icons.self_improvement_rounded,
    'zumba' => Icons.music_note_rounded,
    'boxeo' => Icons.sports_mma_rounded,
    'crossfit' => Icons.bolt_rounded,
    _ => Icons.fitness_center_rounded,
  };

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final full = gymClass.isFullFor(date);
    final ended = gymClass.endedFor(date);
    final active = reserved && !full;

    return PressableScale(
      onTap: onTap,
      pressedScale: 0.975,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active
              ? Color.alphaBlend(
                  brand.accent.withValues(alpha: 0.06),
                  brand.surface,
                )
              : brand.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active
                ? brand.accent.withValues(alpha: 0.55)
                : brand.cardBorder,
            width: active ? 1.4 : 1.0,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: brand.accent.withValues(alpha: 0.14),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(
                    _hhmm(gymClass.startMinutes),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: active ? brand.accent : brand.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${gymClass.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: brand.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 13),
              color: brand.cardBorder,
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: brand.accent.withValues(alpha: active ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconFor(gymClass.category),
                size: 20,
                color: brand.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gymClass.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: brand.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${gymClass.coach} · ${gymClass.room}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: brand.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.event_seat_rounded,
                        size: 11,
                        color: brand.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ended
                            ? 'Terminada'
                            : full
                            ? 'Cupo lleno'
                            : '${gymClass.spotsLeftFor(date)} lugares',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: ended || full
                              ? brand.occupancyHigh
                              : brand.occupancyLow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: active ? brand.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? brand.accent
                      : outOfScope || full || ended
                      ? brand.cardBorder
                      : brand.accent.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (active) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: brand.readableOn(brand.accent),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    active
                        ? 'RESERVADO'
                        : (outOfScope
                              ? 'SOLO TU SEDE'
                              : (ended
                                    ? 'TERMINADA'
                                    : (full ? 'LLENO' : 'RESERVAR'))),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                      color: active
                          ? brand.readableOn(brand.accent)
                          : outOfScope || full || ended
                          ? brand.textSecondary
                          : brand.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
