import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/badge_chip.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/coupon.dart';
import '../../data/repositories/gym_repositories.dart';
import 'providers/promotions_providers.dart';
import 'widgets/coupon_card.dart';
import 'widgets/promo_carousel.dart';

class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  void _redeem(BuildContext context, WidgetRef ref, Coupon coupon) {
    ref.read(redeemedCouponsProvider.notifier).redeem(coupon.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        content: Text(
          'Cupón canjeado · muestra ${coupon.code} en recepción',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    final available = ref.watch(availableCouponsProvider);
    final locked = ref.watch(lockedCouponsProvider);
    final redeemed = ref.watch(redeemedCouponsProvider);
    final promos = ref.watch(promotionsProvider).value ?? mockPromos;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text('Promociones', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Cupones y beneficios para tu nivel ${member?.level ?? 'CLASSIC'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        PromoCarousel(promos: promos),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text('Tus cupones', style: Theme.of(context).textTheme.titleLarge),
            ),
            BadgeChip(
              label: member?.level ?? 'CLASSIC',
              color: member?.isActive ?? false ? brand.occupancyLow : brand.occupancyHigh,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < available.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CouponCard(
              coupon: available[i],
              redeemed: redeemed.contains(available[i].id),
              onRedeem: () => _redeem(context, ref, available[i]),
            )
                .animate(delay: Duration(milliseconds: 120 + i * 100))
                .fadeIn(duration: const Duration(milliseconds: 420))
                .slideY(
                  begin: 0.06,
                  end: 0,
                  duration: const Duration(milliseconds: 480),
                  curve: Curves.easeOutCubic,
                ),
          ),
        if (locked.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Con otro nivel de membresía', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (var i = 0; i < locked.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CouponCard(coupon: locked[i], locked: true)
                  .animate(delay: Duration(milliseconds: 160 + i * 100))
                  .fadeIn(duration: const Duration(milliseconds: 420))
                  .slideY(
                    begin: 0.06,
                    end: 0,
                    duration: const Duration(milliseconds: 480),
                    curve: Curves.easeOutCubic,
                  ),
            ),
        ],
      ],
    );
  }
}
