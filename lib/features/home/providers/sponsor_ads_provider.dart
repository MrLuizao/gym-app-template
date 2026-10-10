import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/sponsor_ad.dart';
import '../../../data/repositories/catalog_repository.dart';

/// Ads activos y vigentes — ya no se segmentan por sede: cualquier
/// anuncio lo ven TODOS los socios de la app.
final sponsorAdsProvider = StreamProvider<List<SponsorAd>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchSponsorAds();
});

/// Espacios simultáneos del carrusel — el producto premium. Cuando hay
/// más de 5 anuncios 'carousel' activos, los 5 más antiguos ocupan el
/// carrusel y el resto espera en el directorio hasta que venza alguno
/// (entra el que compró primero — FIFO por createdAt).
const int kCarouselSlots = 5;

/// Los que se ven en el carrusel del Home y en Promociones — máx.
/// [kCarouselSlots], ordenados por antigüedad de compra.
final carouselAdsProvider = Provider<List<SponsorAd>>((ref) {
  final ads = ref.watch(sponsorAdsProvider).value ?? const <SponsorAd>[];
  final carousel = ads.where((a) => a.placement == 'carousel').toList()
    ..sort(
      (a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
  return carousel.take(kCarouselSlots).toList();
});

/// El directorio de Aliados: primero los del carrusel (fijados al
/// tope — es lo que pagaron), después TODOS los demás en orden
/// aleatorio para que no haya favoritismo — incluye los anuncios de
/// carrusel que están en fila esperando espacio.
final alliesAdsProvider = Provider<List<SponsorAd>>((ref) {
  final ads = ref.watch(sponsorAdsProvider).value ?? const <SponsorAd>[];
  final pinned = ref.watch(carouselAdsProvider);
  final pinnedIds = pinned.map((a) => a.id).toSet();
  final rest = ads.where((a) => !pinnedIds.contains(a.id)).toList()
    ..shuffle();
  return [...pinned, ...rest];
});
