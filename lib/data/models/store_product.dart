/// Firestore: `/store/products/{productId}`
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    this.tag,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String? imageUrl;
  final String? tag;

  factory StoreProduct.fromMap(String id, Map<String, dynamic> map) =>
      StoreProduct(
        id: id,
        name: map['name'] as String? ?? '',
        category: map['category'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        oldPrice: (map['old_price'] as num?)?.toDouble(),
        imageUrl: map['image_url'] as String?,
        tag: map['tag'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'price': price,
    'old_price': oldPrice,
    'image_url': imageUrl,
    'tag': tag,
  };
}
