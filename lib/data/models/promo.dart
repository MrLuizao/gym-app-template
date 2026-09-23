/// Firestore: `/promotions/{promoId}`
class Promo {
  const Promo({
    required this.id,
    required this.title,
    required this.subtitle,
    this.badge = '',
    this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? badge;
  final String? imageUrl;

  factory Promo.fromMap(String id, Map<String, dynamic> map) => Promo(
    id: id,
    title: map['title'] as String? ?? '',
    subtitle: map['subtitle'] as String? ?? '',
    badge: map['badge'] as String? ?? '',
    imageUrl: map['image_url'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'badge': badge,
    'image_url': imageUrl,
  };
}
