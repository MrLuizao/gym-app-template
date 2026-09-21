import 'package:flutter/material.dart';

import '../../../core/branding/brand.dart';
import '../../../core/widgets/badge_chip.dart';
import '../../../core/widgets/cover_image.dart';
import '../../../data/models/trainer.dart';

class TrainerCard extends StatelessWidget {
  const TrainerCard({super.key, required this.trainer, this.onTap});

  final Trainer trainer;
  final VoidCallback? onTap;

  Color _shiftColor(String shift, BrandConfig brand) => switch (shift) {
        'MAÑANA' => brand.occupancyMedium,
        'TARDE' => brand.accent,
        _ => const Color(0xFFA78BFA),
      };

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 138,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brand.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: brand.accent.withValues(alpha: 0.55),
                width: 1.6,
              ),
            ),
            child: ClipOval(
              child: CoverImage(url: trainer.photoUrl, icon: Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            trainer.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            trainer.specialty,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: brand.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          BadgeChip(label: trainer.shift, color: _shiftColor(trainer.shift, brand)),
        ],
      ),
      ),
    );
  }
}
