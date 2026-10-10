import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore: `/sponsorAds/{adId}`
class SponsorAdSocials {
  const SponsorAdSocials({
    this.instagram = '',
    this.facebook = '',
    this.tiktok = '',
    this.website = '',
    this.whatsapp = '',
    this.otherLabel = '',
    this.otherUrl = '',
  });

  final String instagram;
  final String facebook;
  final String tiktok;
  final String website;
  final String whatsapp;

  /// Link libre — el anunciante elige la plataforma y escribe su
  /// propia etiqueta (ej. "YouTube", "X", "Catálogo").
  final String otherLabel;
  final String otherUrl;

  bool get isEmpty =>
      instagram.isEmpty &&
      facebook.isEmpty &&
      tiktok.isEmpty &&
      website.isEmpty &&
      whatsapp.isEmpty &&
      otherUrl.isEmpty;

  factory SponsorAdSocials.fromMap(Map<String, dynamic>? map) =>
      SponsorAdSocials(
        instagram: map?['instagram'] as String? ?? '',
        facebook: map?['facebook'] as String? ?? '',
        tiktok: map?['tiktok'] as String? ?? '',
        website: map?['website'] as String? ?? '',
        whatsapp: map?['whatsapp'] as String? ?? '',
        otherLabel: map?['other_label'] as String? ?? '',
        otherUrl: map?['other_url'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
    'instagram': instagram,
    'facebook': facebook,
    'tiktok': tiktok,
    'website': website,
    'whatsapp': whatsapp,
    'other_label': otherLabel,
    'other_url': otherUrl,
  };
}

class SponsorAd {
  const SponsorAd({
    required this.id,
    required this.advertiser,
    required this.title,
    required this.subtitle,
    this.badge = 'ALIADO',
    this.brandColor,
    this.imageUrl,
    this.ctaLabel = 'Ver oferta',
    this.branchId,
    this.description = '',
    this.address = '',
    this.lat,
    this.lng,
    this.phone = '',
    this.socials = const SponsorAdSocials(),
    this.photos = const [],
    /// Espacio vendido: 'carousel' = premium (carrusel del Home +
    /// Promociones + tope del directorio Aliados, cupo de 5), 'list' =
    /// solo directorio en orden aleatorio. Docs con 'both' o sin el
    /// campo cuentan como carrusel (normalizado en fromMap).
    this.placement = 'carousel',
    this.createdAt,
  });

  final String id;
  final String advertiser;
  final String title;
  final String subtitle;
  final String badge;
  final int? brandColor;
  final String? imageUrl;
  final String ctaLabel;
  final String? branchId;
  final String description;
  final String address;
  final double? lat;
  final double? lng;
  final String phone;
  final SponsorAdSocials socials;
  final List<String> photos;
  final String placement;
  /// Fecha de creación/compra — define el orden FIFO del carrusel:
  /// los 5 más antiguos ocupan los espacios, el resto espera en la
  /// lista hasta que venza alguno.
  final DateTime? createdAt;

  bool get hasLocation => lat != null && lng != null;

  factory SponsorAd.fromMap(String id, Map<String, dynamic> map) => SponsorAd(
    id: id,
    advertiser: map['advertiser'] as String? ?? '',
    title: map['title'] as String? ?? '',
    subtitle: map['subtitle'] as String? ?? '',
    badge: map['badge'] as String? ?? 'ALIADO',
    brandColor: (map['brand_color'] as num?)?.toInt(),
    imageUrl: map['image_url'] as String?,
    ctaLabel: map['cta_label'] as String? ?? 'Ver oferta',
    branchId: map['branch_id'] as String?,
    description: map['description'] as String? ?? '',
    address: map['address'] as String? ?? '',
    lat: (map['lat'] as num?)?.toDouble(),
    lng: (map['lng'] as num?)?.toDouble(),
    phone: map['phone'] as String? ?? '',
    socials: SponsorAdSocials.fromMap(map['socials'] as Map<String, dynamic>?),
    photos: (map['photos'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
    /// 'both' (legacy) y ads sin campo → 'carousel'.
    placement: map['placement'] == 'list' ? 'list' : 'carousel',
    createdAt: map['created_at'] is Timestamp
        ? (map['created_at'] as Timestamp).toDate()
        : null,
  );

  Map<String, dynamic> toMap() => {
    'advertiser': advertiser,
    'title': title,
    'subtitle': subtitle,
    'badge': badge,
    'brand_color': brandColor,
    'image_url': imageUrl,
    'cta_label': ctaLabel,
    'branch_id': branchId,
    'description': description,
    'address': address,
    'lat': lat,
    'lng': lng,
    'phone': phone,
    'socials': socials.toMap(),
    'photos': photos,
    'placement': placement,
  };
}
