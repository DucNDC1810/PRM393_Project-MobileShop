import 'package:flutter/material.dart';

import 'package:project_mobileshop/features/product/services/product_service.dart';

enum LoadStatus { initial, loading, success, error }

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  LoadStatus _status = LoadStatus.initial;
  String? _error;
  String? _selectedCategory;

  // New local filter states
  String? _selectedBrand;
  String? _selectedPriceRange; // 'under_500k', '500k_1m', 'over_1m'
  String? _sortBy; // 'price_asc', 'price_desc'

  List<Map<String, dynamic>> get categories => _categories;
  LoadStatus get status => _status;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get selectedBrand => _selectedBrand;
  String? get selectedPriceRange => _selectedPriceRange;
  String? get sortBy => _sortBy;
  bool get isLoading => _status == LoadStatus.loading;

  // Extract all unique brands from currently loaded products list
  List<String> get availableBrands {
    final Set<String> brands = {};
    for (final p in _products) {
      final b = p['brand']?.toString();
      if (b != null && b.trim().isNotEmpty) {
        brands.add(b.trim());
      }
    }
    final sortedBrands = brands.toList();
    sortedBrands.sort((a, b) => a.compareTo(b));
    return sortedBrands;
  }

  // Filtered and sorted products list
  List<Map<String, dynamic>> get products {
    List<Map<String, dynamic>> list = List.from(_products);

    // 1. Filter by brand
    if (_selectedBrand != null) {
      list = list.where((p) => p['brand']?.toString().toUpperCase() == _selectedBrand!.toUpperCase()).toList();
    }

    // 2. Filter by price range
    if (_selectedPriceRange != null) {
      list = list.where((p) {
        final priceNum = p['price'] as num? ?? 0;
        final price = priceNum.toInt();
        if (_selectedPriceRange == 'under_500k') {
          return price < 500000;
        } else if (_selectedPriceRange == '500k_1m') {
          return price >= 500000 && price <= 1000000;
        } else if (_selectedPriceRange == 'over_1m') {
          return price > 1000000;
        }
        return true;
      }).toList();
    }

    // 3. Sort
    if (_sortBy == 'price_asc') {
      list.sort((a, b) {
        final aPrice = (a['price'] as num? ?? 0).toDouble();
        final bPrice = (b['price'] as num? ?? 0).toDouble();
        return aPrice.compareTo(bPrice);
      });
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) {
        final aPrice = (a['price'] as num? ?? 0).toDouble();
        final bPrice = (b['price'] as num? ?? 0).toDouble();
        return bPrice.compareTo(aPrice);
      });
    }

    return list;
  }

  Future<void> loadProducts({String? category}) async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getProducts(category: category);
      _selectedCategory = category;
      
      // Auto-seed mock data if database is empty
      if (_products.isEmpty && category == null) {
        await _service.seedMockData();
        _products = await _service.getProducts(category: category);
      }

      
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
      
      // Auto-seed mock data if database is empty
      if (_categories.isEmpty) {
        await _service.seedMockData();
        _categories = await _service.getCategories();
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void filterByCategory(String? category) {
    loadProducts(category: category);
    // Reset local filters when switching category
    _selectedBrand = null;
    _selectedPriceRange = null;
    _sortBy = null;
  }

  void setBrand(String? brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  void setPriceRange(String? range) {
    _selectedPriceRange = range;
    notifyListeners();
  }

  void setSortBy(String? sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _selectedBrand = null;
    _selectedPriceRange = null;
    _sortBy = null;
    notifyListeners();
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _service.createProduct(data);
    await loadProducts(category: _selectedCategory);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _service.updateProduct(id, data);
    await loadProducts(category: _selectedCategory);
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
    await loadProducts(category: _selectedCategory);
  }
}
