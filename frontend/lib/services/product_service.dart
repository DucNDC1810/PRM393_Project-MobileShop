import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    String? brand,
    bool? onSale,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection('products')
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (brand != null) {
      query = query.where('brand', isEqualTo: brand);
    }

    final snap = await query.get();

    final products = snap.docs.map((doc) {
      final data = doc.data();
      return <String, dynamic>{
        ...data,
        'id': doc.id,
      };
    }).toList();

    if (onSale == true) {
      return products.where((product) {
        final salePrice = product['sale_price'];
        return salePrice is num && salePrice > 0;
      }).toList();
    }

    return products;
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return <String, dynamic>{
      ...data,
      'id': doc.id,
    };
  }

  Future<List<Map<String, dynamic>>> search(String keyword) async {
    final snap = await _db
        .collection('products')
        .where('is_active', isEqualTo: true)
        .orderBy('name')
        .startAt([keyword])
        .endAt(['$keyword\uf8ff'])
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return <String, dynamic>{
        ...data,
        'id': doc.id,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final snap = await _db
        .collection('categories')
        .where('is_active', isEqualTo: true)
        .orderBy('order')
        .get();

    return snap.docs.map((doc) => doc.data()).toList();
  }
}
