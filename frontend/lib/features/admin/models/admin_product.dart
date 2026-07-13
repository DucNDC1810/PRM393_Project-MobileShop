class AdminProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String ingredients;
  final String skinType;
  final String volume;
  final double price;
  final double discountPrice;
  final int stock;
  final List<String> images;
  final String status;

  AdminProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.skinType,
    required this.volume,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.images,
    required this.status,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      ingredients: json['ingredients'] ?? '',
      skinType: json['skin_type'] ?? json['skinType'] ?? '',
      volume: (json['specs'] as Map<String, dynamic>?)?['volume'] ?? json['volume'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'skinType': skinType,
      'volume': volume,
      'price': price,
      'discountPrice': discountPrice,
      'stock': stock,
      'images': images,
      'status': status,
    };
  }
}
