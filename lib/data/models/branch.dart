/// Firestore: `/branches/{branchId}`
class Branch {
  const Branch({
    required this.id,
    required this.brandId,
    required this.name,
    required this.maxCapacity,
    required this.currentCapacity,
    this.status = 'OPEN',
    this.imageUrl,
    this.address,
  });

  final String id;
  final String brandId;
  final String name;
  final int maxCapacity;
  final int currentCapacity;
  final String status;
  final String? imageUrl;
  final String? address;

  bool get isOpen => status == 'OPEN';
  double get occupancy =>
      maxCapacity <= 0 ? 0 : (currentCapacity / maxCapacity).clamp(0.0, 1.0);

  factory Branch.fromMap(String id, Map<String, dynamic> map) => Branch(
        id: id,
        brandId: map['brand_id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        maxCapacity: (map['max_capacity'] as num?)?.toInt() ?? 0,
        currentCapacity: (map['current_capacity'] as num?)?.toInt() ?? 0,
        status: map['status'] as String? ?? 'OPEN',
        imageUrl: map['image_url'] as String?,
        address: map['address'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'brand_id': brandId,
        'name': name,
        'max_capacity': maxCapacity,
        'current_capacity': currentCapacity,
        'status': status,
        'image_url': imageUrl,
        'address': address,
      };

  Branch copyWith({int? currentCapacity}) => Branch(
        id: id,
        brandId: brandId,
        name: name,
        maxCapacity: maxCapacity,
        currentCapacity: currentCapacity ?? this.currentCapacity,
        status: status,
        imageUrl: imageUrl,
        address: address,
      );
}
