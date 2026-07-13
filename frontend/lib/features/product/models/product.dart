import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String emoji;
  final int price;
  final int salePrice;
  final int stock;
  final List<String> images;
  final String? imageUrl;
  final String ingredients;
  final String skinType;
  final String volume;
  final String howToUse;
  final String origin;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.emoji,
    required this.price,
    required this.salePrice,
    required this.stock,
    required this.images,
    this.imageUrl,
    this.ingredients = '',
    this.skinType = '',
    this.volume = '',
    this.howToUse = '',
    this.origin = '',
  });

  bool get hasDiscount => salePrice > 0 && salePrice < price;
  int get activePrice => hasDiscount ? salePrice : price;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product.fromMap(data, id: doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> data, {String? id}) {
    final specs = data['specs'] as Map<String, dynamic>? ?? {};
    return Product(
      id: id ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '✨',
      price: (data['price'] as num? ?? 0).toInt(),
      salePrice: (data['sale_price'] as num? ?? 0).toInt(),
      stock: (data['stock'] as num? ?? 0).toInt(),
      images: List<String>.from(data['images'] as List? ?? []),
      imageUrl: data['image_url'] as String?,
      ingredients: (specs['ingredients'] ?? data['ingredients'] ?? '') as String,
      skinType: (specs['skin_type'] ?? data['skin_type'] ?? '') as String,
      volume: (specs['volume'] ?? data['volume'] ?? '') as String,
      howToUse: (specs['how_to_use'] ?? data['how_to_use'] ?? '') as String,
      origin: (specs['origin'] ?? data['origin'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'brand': brand,
        'category': category,
        'description': description,
        'emoji': emoji,
        'price': price,
        'sale_price': salePrice,
        'stock': stock,
        'images': images,
        'image_url': imageUrl,
        'specs': {
          'ingredients': ingredients,
          'skin_type': skinType,
          'volume': volume,
          'how_to_use': howToUse,
          'origin': origin,
        },
      };
}
