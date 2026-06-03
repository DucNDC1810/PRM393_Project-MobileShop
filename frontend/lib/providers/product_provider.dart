import 'package:flutter/material.dart';

import '../services/product_service.dart';

enum LoadStatus { initial, loading, success, error }

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  LoadStatus _status = LoadStatus.initial;
  String? _error;
  String? _selectedCategory;

  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  LoadStatus get status => _status;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _status == LoadStatus.loading;

  Future<void> loadProducts({String? category}) async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getProducts(category: category);
      _selectedCategory = category;
      _status = LoadStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = LoadStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _service.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByCategory(String? category) {
    loadProducts(category: category);
  }
}
