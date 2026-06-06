import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  // Map key is product id
  final Map<String, Map<String, dynamic>> _items = {};

  List<Map<String, dynamic>> get items => _items.values.toList();

  int get itemCount {
    return _items.length;
  }

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, value) {
      total += (value['quantity'] as int);
    });
    return total;
  }

  int get totalAmount {
    int total = 0;
    _items.forEach((key, value) {
      final price = (value['price'] as num).toInt();
      final quantity = value['quantity'] as int;
      total += price * quantity;
    });
    return total;
  }

  void addItem(Map<String, dynamic> product, {int quantity = 1}) {
    final id = product['id'] as String;
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existing) => {
          ...existing,
          'quantity': (existing['quantity'] as int) + quantity,
        },
      );
    } else {
      // Extract details
      final num priceVal = product['price'] ?? 0;
      final num salePriceVal = product['sale_price'] ?? 0;
      final bool hasDiscount = salePriceVal > 0 && salePriceVal < priceVal;
      final int activePrice = (hasDiscount ? salePriceVal : priceVal).toInt();

      _items[id] = {
        'id': id,
        'name': product['name'] ?? 'Sản phẩm',
        'brand': product['brand'] ?? 'Beauty & Glow',
        'emoji': product['emoji'] ?? '✨',
        'category': product['category'] ?? '',
        'price': activePrice,
        'quantity': quantity,
      };
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      _items.remove(id);
    } else if (_items.containsKey(id)) {
      _items.update(
        id,
        (existing) => {
          ...existing,
          'quantity': quantity,
        },
      );
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
}
