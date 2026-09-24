import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding/brand.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/models/sponsor_ad.dart';
import '../home/providers/sponsor_ads_provider.dart';
import '../metrics/ad_metrics_provider.dart';

/// Espacio publicitario vendible — rate card estático del prototipo.
/// Los precios varían por ubicación: el carrusel del Home es el
/// premium, el directorio de esta sección es la entrada básica.
class _AdSpace {
  const _AdSpace({
    required this.icon,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    this.badge,
  });

  final IconData icon;
  final String name;
  final String price;
  final String period;
  final String description;
  final String? badge;
}

const _adSpaces = [
  _AdSpace(
    icon: Icons.view_carousel_outlined,
    name: 'Carrusel principal',
    price: r'$1,490',
    period: '/mes',
    description:
        'Tu anuncio rota en el Home de todos los socios con imagen, '
        'badge y botón de acción. Es la ubicación con más alcance.',
    badge: 'MAYOR ALCANCE',
  ),
  _AdSpace(
    icon: Icons.notifications_active_outlined,
    name: 'Push patrocinada',
    price: r'$990',
    period: '/envío',
    description:
        'Notificación directa al celular de los socios con tu oferta. '
        'Se agenda desde la consola con segmentación por sede.',
  ),
  _AdSpace(
    icon: Icons.storefront_outlined,
    name: 'Directorio de Aliados',
    price: r'$490',
    period: '/mes',
    description:
        'Tu ficha completa en esta sección: descripción, fotos, '
        'ubicación y redes. Presencia permanente sin rotación.',
    badge: 'BÁSICO',
  ),
];

class AlliesScreen extends ConsumerWidget {
  const AlliesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    final ads = ref.watch(sponsorAdsProvider).value ?? const [];
    /// Los aliados con espacio premium van primero en el directorio.
    final sorted = [...ads]..sort(
        (a, b) => (a.placement == 'carousel' ? 0 : 1).compareTo(
          b.placement == 'carousel' ? 0 : 1,
        ),
      );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
      children: [
        Text('Aliados', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Las marcas que apoyan tu entrenamiento',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _AdSpacesSheet.show(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: brand.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: brand.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: brand.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: brand.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
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
                        'Anuncia tu marca aquí',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: brand.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Espacios publicitarios desde \$490/mes',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: brand.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: brand.accent,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'NUESTROS ALIADOS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.4,
            color: brand.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: brand.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: brand.cardBorder),
            ),
            child: Text(
              'Aún no hay aliados activos',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final ad in sorted) ...[
            _AllyCard(ad: ad),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

/// Rate card de espacios publicitarios — modal bottom sheet.
class _AdSpacesSheet extends StatelessWidget {
  const _AdSpacesSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AdSpacesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
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
          Text(
            'Espacios publicitarios',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: brand.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'El precio varía por ubicación — el carrusel del Home es el '
            'espacio premium.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: brand.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (final space in _adSpaces) ...[
            _AdSpaceCard(space: space),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: brand.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: brand.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 18,
                  color: brand.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '¿Quieres anunciar tu marca? Pregunta en recepción por '
                    'la disponibilidad de espacios.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: brand.accent,
                    ),
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

class _AdSpaceCard extends StatelessWidget {
  const _AdSpaceCard({required this.space});

  final _AdSpace space;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final highlight = space.badge == 'MAYOR ALCANCE';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brand.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight ? brand.accent.withValues(alpha: 0.55) : brand.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: brand.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: brand.accent.withValues(alpha: 0.4)),
            ),
            child: Icon(space.icon, size: 20, color: brand.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        space.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: brand.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      space.price,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: brand.accent,
                      ),
                    ),
                    Text(
                      space.period,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (space.badge != null) ...[
                  const SizedBox(height: 6),
                  BadgeChip(label: space.badge!, color: brand.accent),
                ],
                const SizedBox(height: 6),
                Text(
                  space.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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

class _AllyCard extends ConsumerWidget {
  const _AllyCard({required this.ad});

  final SponsorAd ad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = context.brand;
    return GestureDetector(
      onTap: () {
        ref.read(adMetricsProvider.notifier).track(ad.id, 'tap');
        Navigator.of(context).pushNamed('/sponsor', arguments: ad);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: brand.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: brand.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 56,
                height: 56,
                child: CoverImage(
                  url: ad.imageUrl,
                  icon: Icons.storefront_outlined,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          ad.advertiser.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: brand.accent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (ad.placement == 'carousel') ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: brand.accent,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ad.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: brand.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ad.subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: brand.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: brand.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
