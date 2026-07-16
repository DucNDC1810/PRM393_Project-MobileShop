class CartItem {
  final String id;
  final String name;
  final String brand;
  final String emoji;
  final String category;
  final int price;
  int quantity;
  final List<String>? images;
  final String? imageUrl;
  final int stock;

  CartItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.emoji,
    required this.category,
    required this.price,
    required this.quantity,
    this.images,
    this.imageUrl,
    this.stock = 999,
  });

  int get subtotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        name: name,
        brand: brand,
        emoji: emoji,
        category: category,
        price: price,
        quantity: quantity ?? this.quantity,
        images: images,
        imageUrl: imageUrl,
        stock: stock,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'emoji': emoji,
        'category': category,
        'price': price,
        'quantity': quantity,
        'images': images,
        'image_url': imageUrl,
        'stock': stock,
      };
}
