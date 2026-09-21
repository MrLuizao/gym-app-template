import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../data/models/gym_class.dart';

class ClassTile extends StatelessWidget {
  const ClassTile({
    super.key,
    required this.gymClass,
    required this.reserved,
    this.onToggle,
    this.onTap,
  });

  final GymClass gymClass;
  final bool reserved;
  final VoidCallback? onToggle;
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
    final full = gymClass.isFull;
    final active = reserved && !full;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: brand.cardBorder),
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
                    color: brand.textPrimary,
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
          Icon(_iconFor(gymClass.category), size: 22, color: brand.accent),
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
                    Icon(Icons.event_seat_rounded,
                        size: 11, color: brand.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      full ? 'Cupo lleno' : '${gymClass.spotsLeft} lugares',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: full ? brand.occupancyHigh : brand.occupancyLow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: full ? null : onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: active ? brand.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? brand.accent
                      : full
                          ? brand.cardBorder
                          : brand.accent.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                active ? 'RESERVADO' : (full ? 'LLENO' : 'RESERVAR'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: active
                      ? Colors.white
                      : full
                          ? brand.textSecondary
                          : brand.accent,
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
