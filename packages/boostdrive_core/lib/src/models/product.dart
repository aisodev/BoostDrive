class Product {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final List<String> imageUrls;
  final String location;
  final bool isFeatured;
  final String category; // 'car', 'part', 'rental'
  
  // REAL DATA FIELDS
  final String condition; // 'new', 'used', 'salvage'
  final Map<String, dynamic>? fitment; // { 'make': 'Toyota', 'model': 'Hilux', 'year': 2020 }
  final String? sellerId;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrls,
    required this.location,
    this.isFeatured = false,
    required this.category,
    this.condition = 'used',
    this.fitment,
    this.sellerId,
    this.createdAt,
  });

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory Product.fromMap(Map<String, dynamic> data, {String? id}) {
    return Product(
      id: id ?? data['id'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: data['image_urls'] != null 
          ? List<String>.from(data['image_urls']) 
          : (data['image_url'] != null ? [data['image_url'] as String] : []),
      location: data['location'] ?? 'Namibia',
      isFeatured: data['is_featured'] ?? false,
      category: data['category'] ?? 'car',
      condition: data['condition'] ?? 'used',
      fitment: data['fitment'] != null ? Map<String, dynamic>.from(data['fitment']) : null,
      sellerId: data['seller_id'],
      createdAt: data['created_at'] != null 
          ? DateTime.tryParse(data['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'image_urls': imageUrls,
      'image_url': imageUrl, 
      'location': location,
      'is_featured': isFeatured,
      'category': category,
      'condition': condition,
      if (fitment != null) 'fitment': fitment,
      if (sellerId != null) 'seller_id': sellerId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? price,
    List<String>? imageUrls,
    String? location,
    bool? isFeatured,
    String? category,
    String? condition,
    Map<String, dynamic>? fitment,
    String? sellerId,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      isFeatured: isFeatured ?? this.isFeatured,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      fitment: fitment ?? this.fitment,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
