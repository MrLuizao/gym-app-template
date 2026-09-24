import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand.dart';
import '../../../core/firebase/api_client.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/capacity_bar.dart';
import '../../../data/models/gym_class.dart';
import '../providers/reservation_provider.dart';

class ClassDetailSheet extends ConsumerWidget {
  const ClassDetailSheet({
    super.key,
    required this.gymClass,
    required this.date,
  });

  final GymClass gymClass;

  /// Fecha `YYYY-MM-DD` de la ocurrencia (selector de día en la lista).
  final String date;

  static Future<void> show(
    BuildContext context,
    GymClass gymClass, {
    required String date,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClassDetailSheet(gymClass: gymClass, date: date),
    );
  }

  IconData _iconFor(String category) => switch (category) {
    'spinning' => Icons.directions_bike_rounded,
    'yoga' => Icons.self_improvement_rounded,
    'zumba' => Icons.music_note_rounded,
    'boxeo' => Icons.sports_mma_rounded,
    'crossfit' => Icons.bolt_rounded,
    _ => Icons.fitness_center_rounded,
  };

  String _categoryLabel(String category) => switch (category) {
    'spinning' => 'Cycling',
    'yoga' => 'Mente & cuerpo',
    'zumba' => 'Ritmo',
    'boxeo' => 'Combate',
    'crossfit' => 'Alta intensidad',
    _ => 'Fuerza',
  };

  String _categoryDescription(String category) => switch (category) {
    'spinning' =>
      'Ciclismo indoor guiado por música e intervalos. Trabajo cardiovascular '
          'intenso con cambios de resistencia y ritmo.',
    'yoga' =>
      'Secuencia de movilidad, respiración y equilibrio para soltar la '
          'tensión del entrenamiento y mejorar la flexibilidad.',
    'zumba' =>
      'Cardio bailado con coreografías fáciles de seguir. Quema calorías '
          'sin que se sienta como ejercicio.',
    'boxeo' =>
      'Técnica de golpes, combinaciones y acondicionamiento físico '
          'sobre el ring. Guantes disponibles en recepción.',
    'crossfit' =>
      'Intervalos funcionales de alta intensidad: fuerza, cardio y '
          'potencia en un solo bloque.',
    _ =>
      'Entrenamiento grupal guiado por un coach certificado, adaptable '
          'a todos los niveles.',
  };

  String _hhmm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final reserved = ref
        .watch(reservedClassesProvider)
        .contains(
          ReservedClassesNotifier.keyOf(
            gymClass.id,
            gymClass.branchId,
            date,
          ),
        );
    final full = gymClass.isFullFor(date);
    final booked = gymClass.bookedFor(date);

    return Container(
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: brand.cardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: brand.cardBorder,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: brand.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: brand.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(
                  _iconFor(gymClass.category),
                  size: 26,
                  color: brand.accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymClass.name,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: brand.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    BadgeChip(
                      label: _categoryLabel(gymClass.category).toUpperCase(),
                      color: brand.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _categoryDescription(gymClass.category),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: brand.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Row(
              children: [
                _InfoCell(
                  icon: Icons.schedule_rounded,
                  label: 'Horario',
                  value:
                      '${_hhmm(gymClass.startMinutes)} – ${_hhmm(gymClass.endMinutes)}',
                ),
                _InfoCell(
                  icon: Icons.timer_outlined,
                  label: 'Duración',
                  value: '${gymClass.durationMinutes} min',
                ),
                _InfoCell(
                  icon: Icons.meeting_room_rounded,
                  label: 'Sala',
                  value: gymClass.room,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: brand.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 15,
                      color: brand.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Coach · ${gymClass.coach}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: brand.textPrimary,
                        ),
                      ),
                    ),
                    BadgeChip(
                      label: full
                          ? 'CUPO LLENO'
                          : '${gymClass.spotsLeftFor(date)} LUGARES',
                      color: full ? brand.occupancyHigh : brand.occupancyLow,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CapacityBar(
                  value: gymClass.capacity > 0
                      ? booked / gymClass.capacity
                      : 0,
                  height: 6,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$booked/${gymClass.capacity} inscritos',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: brand.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ReserveButton(
            gymClass: gymClass,
            date: date,
            reserved: reserved,
            full: full,
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 15, color: brand.accent),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReserveButton extends ConsumerStatefulWidget {
  const _ReserveButton({
    required this.gymClass,
    required this.date,
    required this.reserved,
    required this.full,
  });

  final GymClass gymClass;
  final String date;
  final bool reserved;
  final bool full;

  @override
  ConsumerState<_ReserveButton> createState() => _ReserveButtonState();
}

class _ReserveButtonState extends ConsumerState<_ReserveButton> {
  bool _busy = false;
  String? _error;

  static String _ddmm(String date) =>
      '${date.substring(8, 10)}/${date.substring(5, 7)}';

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(reservedClassesProvider.notifier)
          .toggle(
            widget.gymClass.id,
            branchId: widget.gymClass.branchId,
            date: widget.date,
          );
    } catch (e) {
      /// El error vive dentro del sheet — un SnackBar del Scaffold quedaría
      /// tapado por el propio bottom sheet.
      if (mounted) {
        setState(
          () => _error = e is ApiException
              ? (e.serverMessage ?? 'No se pudo completar la reserva')
              : 'No se pudo completar la reserva',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final reserved = widget.reserved;
    final full = widget.full;
    final ended = widget.gymClass.endedFor(widget.date);
    final isToday = widget.date == GymClass.dateKey(DateTime.now());

    /// Banner de error inline — el SnackBar del Scaffold queda tapado por
    /// el bottom sheet, así que el mensaje vive aquí con el mismo lenguaje
    /// visual del resto del modal.
    final errorBanner = _error == null
        ? null
        : Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: brand.occupancyHigh.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: brand.occupancyHigh.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: brand.occupancyHigh,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: brand.occupancyHigh,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _error = null),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: brand.occupancyHigh.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );

    if ((full || ended) && !reserved) {
      final button = Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: brand.cardBorder.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          ended ? 'CLASE TERMINADA' : 'CUPO LLENO',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: brand.textSecondary,
          ),
        ),
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [?errorBanner, button],
      );
    }
    final action = GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: reserved
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [brand.accent, brand.accentDark],
                ),
          border: reserved ? Border.all(color: brand.accent, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: reserved ? brand.accent : brand.background,
                ),
              )
            else
              Icon(
                reserved
                    ? Icons.check_circle_rounded
                    : Icons.event_seat_rounded,
                size: 18,
                color: reserved ? brand.accent : brand.background,
              ),
            const SizedBox(width: 8),
            Text(
              reserved
                  ? 'RESERVA ACTIVA · TOCAR PARA CANCELAR'
                  : isToday
                  ? 'RESERVAR LUGAR'
                  : 'RESERVAR PARA EL ${_ddmm(widget.date)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: reserved ? brand.accent : brand.background,
              ),
            ),
          ],
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [?errorBanner, action],
    );
  }
}
