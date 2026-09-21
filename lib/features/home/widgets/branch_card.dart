import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/capacity_bar.dart';
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
    final statusColor = branch.isOpen ? brand.occupancyLow : brand.occupancyHigh;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: SizedBox(
        height: 192,
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
              right: 84,
              child: Row(
                children: [
                  if (onToggleFavorite != null)
                    GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.45),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite ? brand.accent : Colors.white,
                        ),
                      ),
                    ),
                  if (onToggleFavorite != null) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.05,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        BadgeChip(
                          label: branch.isOpen ? 'ABIERTA' : 'CERRADA',
                          color: statusColor,
                          icon: Icons.circle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                ),
                child: Center(
                  child: CapacityRing(value: ratio, size: 46, strokeWidth: 5),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                children: [
                  Row(
                    children: [
                      BadgeChip(
                        label: brand.occupancyLabelFor(ratio),
                        color: brand.occupancyFor(ratio),
                      ),
                      const Spacer(),
                      Text(
                        '${branch.currentCapacity}/${branch.maxCapacity} cupos',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CapacityBar(value: ratio, height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
