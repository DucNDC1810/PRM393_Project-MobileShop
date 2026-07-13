import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  /// Returns items as maps for backward compatibility with screens that use Map API.
  List<Map<String, dynamic>> get itemsAsMap =>
      _items.values.map((item) => item.toMap()).toList();

  int get itemCount => _items.length;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get totalAmount =>
      _items.values.fold(0, (sum, item) => sum + item.subtotal);

  void addItem(Map<String, dynamic> product, {int quantity = 1}) {
    final id = product['id'] as String;
    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(
        quantity: _items[id]!.quantity + quantity,
      );
    } else {
      final num priceVal = product['price'] as num? ?? 0;
      final num salePriceVal = product['sale_price'] as num? ?? 0;
      final bool hasDiscount = salePriceVal > 0 && salePriceVal < priceVal;
      final int activePrice = (hasDiscount ? salePriceVal : priceVal).toInt();

      _items[id] = CartItem(
        id: id,
        name: product['name'] as String? ?? 'Sản phẩm',
        brand: product['brand'] as String? ?? 'Beauty & Glow',
        emoji: product['emoji'] as String? ?? '✨',
        category: product['category'] as String? ?? '',
        price: activePrice,
        quantity: quantity,
        images: product['images'] != null
            ? List<String>.from(product['images'] as List)
            : null,
        imageUrl: product['image_url'] as String?,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      _items.remove(id);
    } else if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Convert all items to a list of maps for Firestore order documents.
  List<Map<String, dynamic>> toOrderItems() =>
      _items.values.map((item) => item.toMap()).toList();
}
