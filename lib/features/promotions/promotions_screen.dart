import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../data/repositories/gym_repositories.dart';
import '../home/providers/sponsor_ads_provider.dart';
import '../home/widgets/sponsor_carousel.dart';
import '../payments/providers/membership_provider.dart';
import 'providers/promotions_providers.dart';
import 'widgets/coupon_card.dart';
import 'widgets/coupon_qr_sheet.dart';

class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final member = ref.watch(memberProvider).value;
    final generated = ref.watch(generatedCouponsProvider).values.toList();
    final memberCoupons = ref.watch(availableCouponsProvider);
    final locked = ref.watch(lockedCouponsProvider);
    /// Solo los espacios 'carousel' — el directorio ('list') vive
    /// en la pestaña Aliados.
    final ads = (ref.watch(sponsorAdsProvider).value ?? const [])
        .where((a) => a.placement == 'carousel')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text('Promociones', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Cupones y beneficios para tu ${member?.planId.isNotEmpty == true ? planNameFor(member!.planId) : 'membresía'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        if (ads.isNotEmpty) ...[
          Text(
            'OFERTAS DE NUESTROS ALIADOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.4,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SponsorCarousel(ads: ads),
          const SizedBox(height: 24),
        ],
        Text(
          'Cupones de aliados',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Los que generas desde el detalle de cada aliado',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (generated.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: brand.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.confirmation_num_outlined,
                  size: 30,
                  color: brand.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  'Aún no tienes cupones',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Genera uno desde el detalle de un aliado '
                  'con "Generar cupón".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        for (var i = 0; i < generated.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                CouponCard(
                      coupon: generated[i],
                      onTap: () => CouponQrSheet.show(context, generated[i]),
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
        if (memberCoupons.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Beneficios de tu membresía',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < memberCoupons.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  CouponCard(
                        coupon: memberCoupons[i],
                        onTap: () =>
                            CouponQrSheet.show(context, memberCoupons[i]),
                      )
                      .animate(delay: Duration(milliseconds: 140 + i * 100))
                      .fadeIn(duration: const Duration(milliseconds: 420))
                      .slideY(
                        begin: 0.06,
                        end: 0,
                        duration: const Duration(milliseconds: 480),
                        curve: Curves.easeOutCubic,
                      ),
            ),
        ],
        if (locked.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Con otro nivel de membresía',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
