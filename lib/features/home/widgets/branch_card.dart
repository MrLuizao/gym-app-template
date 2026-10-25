import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/branding/brand.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/capacity_ring.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../data/models/branch.dart';

class BranchCard extends StatelessWidget {
  const BranchCard({
    super.key,
    required this.branch,
    this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final Branch branch;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final ratio = branch.occupancy;
    final statusColor = branch.isOpen
        ? brand.occupancyLow
        : brand.occupancyHigh;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: SizedBox(
        height: 158,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CoverImage(url: branch.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.88),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 16,
              right: 110,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            branch.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: brand.accent,
                              height: 1.05,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (onToggleFavorite != null)
              Positioned(
                right: 14,
                top: 14,
                child: GestureDetector(
                  onTap: () {
                    AppHaptics.medium();
                    onToggleFavorite!();
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                      border: Border.all(
                        color: isFavorite
                            ? brand.accent.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: AnimatedScale(
                      scale: isFavorite ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: isFavorite ? brand.accent : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: statusColor.withValues(alpha: 0.65)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LivePulseDot(color: statusColor, active: branch.isOpen),
                    const SizedBox(width: 6),
                    Text(
                      branch.isOpen ? 'EN VIVO' : 'CERRADA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 14,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AFORO ACTUAL',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            end: branch.currentCapacity.toDouble(),
                          ),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) => Text(
                            '${val.round()}/${branch.maxCapacity} cupos',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Center(
                      child: CapacityRing(
                        value: ratio,
                        size: 38,
                        strokeWidth: 4,
                      ),
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

class _LivePulseDot extends StatelessWidget {
  const _LivePulseDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Icon(Icons.circle, size: 7, color: color);
    }
    return SizedBox(
      width: 11,
      height: 11,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.45),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.5, 1.5),
                duration: 1400.ms,
                curve: Curves.easeOut,
              )
              .fadeOut(duration: 1400.ms),
          Container(
            width: 6.5,
            height: 6.5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}
