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
        .where('is_active', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (brand != null) {
      query = query.where('brand', isEqualTo: brand);
    }

    final snap = await query.get();

    var products = snap.docs.map((doc) {
      final data = doc.data();
      return <String, dynamic>{...data, 'id': doc.id};
    }).toList();

    // sort client-side để tránh cần composite index
    products.sort((a, b) {
      final aTime = a['created_at'];
      final bTime = b['created_at'];
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    if (onSale == true) {
      return products.where((p) {
        final salePrice = p['sale_price'];
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
