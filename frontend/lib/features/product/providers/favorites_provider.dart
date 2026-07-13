import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _favorites = {};

  List<Map<String, dynamic>> get items => _favorites.values.toList();

  int get itemCount => _favorites.length;

  bool isFavorite(String id) {
    return _favorites.containsKey(id);
  }

  void toggleFavorite(Map<String, dynamic> product) {
    final id = product['id']?.toString() ?? '';
    if (id.isEmpty) return;

    if (_favorites.containsKey(id)) {
      _favorites.remove(id);
    } else {
      _favorites[id] = product;
    }
    notifyListeners();
  }

  void removeFavorite(String id) {
    if (_favorites.containsKey(id)) {
      _favorites.remove(id);
      notifyListeners();
    }
  }

  void clear() {
    _favorites.clear();
    notifyListeners();
  }
}
