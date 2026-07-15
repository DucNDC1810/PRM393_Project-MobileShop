import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _favorites = {};
  String? _uid;

  List<Map<String, dynamic>> get items => _favorites.values.toList();
  int get itemCount => _favorites.length;

  bool isFavorite(String id) => _favorites.containsKey(id);

  /// Call after login with the user's uid to load persisted favorites.
  Future<void> loadForUser(String uid) async {
    _uid = uid;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final raw = doc.data()?['favorites'];
      _favorites.clear();
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            final product = Map<String, dynamic>.from(item);
            final id = product['id']?.toString() ?? '';
            if (id.isNotEmpty) _favorites[id] = product;
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }
  }

  Future<void> _persist() async {
    if (_uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .update({'favorites': _favorites.values.toList()});
    } catch (e) {
      debugPrint('Failed to persist favorites: $e');
    }
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
    _persist();
  }

  void removeFavorite(String id) {
    if (_favorites.containsKey(id)) {
      _favorites.remove(id);
      notifyListeners();
      _persist();
    }
  }

  void clear() {
    _favorites.clear();
    _uid = null;
    notifyListeners();
  }
}
