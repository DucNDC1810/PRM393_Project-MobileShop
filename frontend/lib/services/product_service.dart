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

  Future<void> createProduct(Map<String, dynamic> data) async {
    data['created_at'] = FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();
    await _db.collection('products').add(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _db.collection('products').doc(id).update(data);
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final snap = await _db
        .collection('categories')
        .where('is_active', isEqualTo: true)
        .orderBy('order')
        .get();

    return snap.docs.map((doc) => doc.data()).toList();
  }

  Future<void> seedMockData() async {
    final now = Timestamp.now();
    
    // Seed Categories
    final categories = [
      { 'id': 'cat_skincare', 'name': 'Dưỡng da (Skincare)', 'slug': 'skincare', 'icon': '🧴', 'order': 1, 'is_active': true },
      { 'id': 'cat_makeup', 'name': 'Trang điểm (Makeup)', 'slug': 'makeup', 'icon': '💄', 'order': 2, 'is_active': true },
      { 'id': 'cat_perfume', 'name': 'Nước hoa (Perfume)', 'slug': 'perfume', 'icon': '🧪', 'order': 3, 'is_active': true },
      { 'id': 'cat_accessories', 'name': 'Phụ kiện (Accessories)', 'slug': 'accessories', 'icon': '🖌️', 'order': 4, 'is_active': true },
    ];
    
    final batch = _db.batch();
    for (var cat in categories) {
      final ref = _db.collection('categories').doc(cat['id'] as String);
      batch.set(ref, cat);
    }
    
    // Seed Products
    final products = [
      {
        'sku': 'BGL-LUM-VITC-50',
        'name': 'Hydrating Glow Serum with Vitamin C',
        'brand': 'LUMIÈRE',
        'category': 'skincare',
        'category_id': 'cat_skincare',
        'emoji': '🧴',
        'images': ['https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=600&q=80'],
        'price': 1100000,
        'sale_price': 0,
        'description': 'Serum dưỡng ẩm làm sáng da cao cấp với Vitamin C và chiết xuất thảo mộc hữu cơ. Thấm sâu giúp làn da luôn căng bóng, rạng rỡ tự nhiên.',
        'specs': {
          'volume': '50ml',
          'origin': 'Pháp (France)',
          'skin_type': 'Mọi loại da, đặc biệt là da xỉn màu',
          'key_ingredients': 'Vitamin C, Hyaluronic Acid, Rose Gold extract',
          'usage': 'Thoa 2-3 giọt mỗi buổi sáng và tối trước khi bôi kem dưỡng.'
        },
        'stock': 100,
        'is_active': true,
        'tags': ['new', 'best_seller'],
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-ESE-MATTE-RP',
        'name': 'Velvet Matte Lipstick - Rose Petal',
        'brand': 'ESENCE',
        'category': 'makeup',
        'category_id': 'cat_makeup',
        'emoji': '💄',
        'images': ['https://images.unsplash.com/photo-1631214524020-3c69f88b86c4?w=600&q=80'],
        'price': 750000,
        'sale_price': 550000,
        'description': 'Son lì mịn mượt như nhung tông màu Cánh Hồng Khô (Rose Petal) thời thượng. Không gây khô môi, giữ màu lâu trôi lên đến 8 giờ.',
        'specs': {
          'weight': '3.5g',
          'finish': 'Matte (Lì mịn)',
          'shade': 'Rose Petal (Hồng cánh hoa)',
          'features': 'Chứa dưỡng chất từ dầu Jojoba và Vitamin E nuôi dưỡng môi',
          'origin': 'Ý (Italy)'
        },
        'stock': 120,
        'is_active': true,
        'tags': ['best_seller'],
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-AUR-EDP-MJ100',
        'name': 'Eau de Parfum - Midnight Jasmine',
        'brand': 'AURUM',
        'category': 'perfume',
        'category_id': 'cat_perfume',
        'emoji': '🧪',
        'images': ['https://images.unsplash.com/photo-1590156206657-aec4e696ef72?w=600&q=80'],
        'price': 2800000,
        'sale_price': 0,
        'description': 'Nước hoa cao cấp hương Hoa Lài Đêm huyền bí và sang trọng. Nốt hương nồng ấm quyến rũ thích hợp cho các buổi tiệc tối thanh lịch.',
        'specs': {
          'volume': '100ml',
          'concentration': 'Eau de Parfum (EDP)',
          'scent_family': 'Floral Woody (Hương hoa và gỗ ấm)',
          'notes': 'Hương đầu: Cam Bergamot. Hương giữa: Hoa lài đêm. Hương cuối: Gỗ đàn hương, Hổ phách',
          'longevity': '6 - 8 giờ'
        },
        'stock': 35,
        'is_active': true,
        'tags': ['new'],
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-PUR-FACE-ROSE',
        'name': 'Botanical Face Oil with Rosehip',
        'brand': 'PURE',
        'category': 'skincare',
        'category_id': 'cat_skincare',
        'emoji': '🧴',
        'images': ['https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=600&q=80'],
        'price': 1300000,
        'sale_price': 0,
        'description': 'Dầu dưỡng da chiết xuất hạt tầm xuân hữu cơ giúp làm dịu, tái tạo và nuôi dưỡng làn da khô ráp, mang lại vẻ mềm mại tự nhiên.',
        'specs': {
          'volume': '30ml',
          'ingredients': '100% Organic Rosehip Seed Oil',
          'benefits': 'Giảm thâm sạm, dưỡng ẩm sâu, mờ vết nhăn li ti',
          'origin': 'Úc (Australia)',
          'usage': 'Massage 2-3 giọt lên mặt ẩm sau bước serum.'
        },
        'stock': 60,
        'is_active': true,
        'tags': ['best_seller'],
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-ART-BRUSH-5P',
        'name': 'Essential Brush Set (5 Piece)',
        'brand': 'ARTISTRY',
        'category': 'accessories',
        'category_id': 'cat_accessories',
        'emoji': '🖌️',
        'images': ['https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600&q=80'],
        'price': 1050000,
        'sale_price': 880000,
        'description': 'Bộ cọ trang điểm thiết yếu 5 món với lông cọ nhân tạo siêu mềm mịn và cổ cọ mạ vàng hồng (Rose Gold) sang chảnh đi kèm bao da tiện dụng.',
        'specs': {
          'count': '5 cây cọ trang điểm chuyên dụng',
          'material': 'Sợi nhân tạo mềm mại thuần chay, thân gỗ cao cấp',
          'includes': 'Cọ phấn phủ, cọ má hồng, cọ tán nền, cọ bầu mắt, cọ kẻ viền',
          'clean': 'Rửa định kỳ bằng dung dịch giặt cọ chuyên dụng'
        },
        'stock': 80,
        'is_active': true,
        'tags': [],
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-LUM-EYEPAL-CE',
        'name': 'Celestial Glow Eyeshadow Palette',
        'brand': 'LUMIÈRE',
        'category': 'makeup',
        'category_id': 'cat_makeup',
        'emoji': '🎨',
        'images': ['https://images.unsplash.com/photo-1617897903246-719242758050?w=600&q=80'],
        'price': 1480000,
        'sale_price': 0,
        'description': 'Bảng phấn mắt 12 màu sang trọng kết hợp các tông màu lì ấm áp và màu nhũ lấp lánh lung linh giúp đôi mắt cuốn hút rạng rỡ suốt ngày dài.',
        'specs': {
          'shades': '12 màu đa dạng (Lì & Nhũ lấp lánh)',
          'finish': 'Matte & Shimmer',
          'weight': '15g',
          'features': 'Phấn mịn dễ tán, lên màu chuẩn và lâu trôi'
        },
        'stock': 50,
        'is_active': true,
        'tags': ['new'],
        'created_at': now,
        'updated_at': now,
      }
    ];

    for (var prod in products) {
      final ref = _db.collection('products').doc();
      batch.set(ref, prod);
    }

    await batch.commit();
  }

  Future<void> deleteAllProducts() async {
    final snap = await _db.collection('products').get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> seedAdditionalProducts() async {
    final now = Timestamp.now();
    final batch = _db.batch();

    final products = [
      // ── SKINCARE (thêm 3) ──────────────────────────────────────────────────
      {
        'sku': 'BGL-LUM-TONER-50',
        'name': 'Brightening Toner with Niacinamide',
        'brand': 'LUMIÈRE',
        'category': 'skincare',
        'category_id': 'cat_skincare',
        'emoji': '🧴',
        'images': ['https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=600&q=80'],
        'price': 650000,
        'sale_price': 520000,
        'description': 'Toner làm sáng da chứa Niacinamide 10% và chiết xuất cam thảo giúp thu nhỏ lỗ chân lông, đều màu da và kiểm soát dầu nhờn hiệu quả.',
        'specs': {
          'volume': '150ml',
          'key_ingredients': 'Niacinamide 10%, Licorice Extract, Panthenol',
          'skin_type': 'Da dầu, da hỗn hợp, da thâm sạm',
          'origin': 'Hàn Quốc',
          'usage': 'Thoa lên mặt sau bước rửa mặt, dùng bông tẩy trang hoặc tay.'
        },
        'stock': 150,
        'is_active': true,
        'tags': ['best_seller', 'new'],
        'rating': 4.9,
        'reviews': 234,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-PUR-SUNSCREEN-50',
        'name': 'Invisible Sunscreen SPF 50+',
        'brand': 'PURE',
        'category': 'skincare',
        'category_id': 'cat_skincare',
        'emoji': '☀️',
        'images': ['https://images.unsplash.com/photo-1556228720-195a672e8a03?w=600&q=80'],
        'price': 480000,
        'sale_price': 0,
        'description': 'Kem chống nắng vô hình SPF 50+ PA++++ bảo vệ tối đa trước tia UV, không bết dính, không để lại vệt trắng — phù hợp làm nền trang điểm.',
        'specs': {
          'volume': '50ml',
          'spf': 'SPF 50+ PA++++',
          'texture': 'Gel loãng, thấm nhanh',
          'skin_type': 'Mọi loại da',
          'origin': 'Nhật Bản',
        },
        'stock': 200,
        'is_active': true,
        'tags': ['best_seller'],
        'rating': 4.8,
        'reviews': 412,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-ESE-MASK-CLAY',
        'name': 'Purifying Clay Mask with Charcoal',
        'brand': 'ESENCE',
        'category': 'skincare',
        'category_id': 'cat_skincare',
        'emoji': '🫧',
        'images': ['https://images.unsplash.com/photo-1596755389378-c31d21fd1273?w=600&q=80'],
        'price': 390000,
        'sale_price': 320000,
        'description': 'Mặt nạ đất sét kết hợp than hoạt tính hút sạch bụi bẩn, bã nhờn và chất độc ẩn sâu trong lỗ chân lông, trả lại làn da thông thoáng và mịn màng.',
        'specs': {
          'volume': '75ml',
          'key_ingredients': 'Kaolin Clay, Activated Charcoal, Tea Tree Oil',
          'usage': 'Thoa đều lên mặt, để 10-15 phút rồi rửa sạch. Dùng 2-3 lần/tuần.',
          'skin_type': 'Da dầu, da mụn, da hỗn hợp',
          'origin': 'Anh Quốc',
        },
        'stock': 90,
        'is_active': true,
        'tags': ['new'],
        'rating': 4.7,
        'reviews': 98,
        'created_at': now,
        'updated_at': now,
      },

      // ── MAKEUP (thêm 3) ────────────────────────────────────────────────────
      {
        'sku': 'BGL-LUM-FOUNDATION-02',
        'name': 'Satin Finish Foundation - Shade 02',
        'brand': 'LUMIÈRE',
        'category': 'makeup',
        'category_id': 'cat_makeup',
        'emoji': '✨',
        'images': ['https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&q=80'],
        'price': 920000,
        'sale_price': 0,
        'description': 'Kem nền lên màu chuẩn, độ che phủ vừa phải với finish satin mịn lụa. Công thức chứa Hyaluronic Acid giúp da căng bóng tự nhiên suốt 16 giờ.',
        'specs': {
          'volume': '30ml',
          'coverage': 'Vừa - Cao (buildable)',
          'finish': 'Satin',
          'shade': '02 - Natural Beige',
          'longevity': '16 giờ',
          'origin': 'Pháp',
        },
        'stock': 75,
        'is_active': true,
        'tags': ['new'],
        'rating': 4.8,
        'reviews': 156,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-ART-MASCARA-VOL',
        'name': 'Volume & Curl Mascara - Black',
        'brand': 'ARTISTRY',
        'category': 'makeup',
        'category_id': 'cat_makeup',
        'emoji': '👁️',
        'images': ['https://images.unsplash.com/photo-1631214524020-3c69f88b86c4?w=600&q=80'],
        'price': 420000,
        'sale_price': 350000,
        'description': 'Mascara tạo khối và uốn cong mi tự nhiên với công thức không thấm nước. Cọ xoắn ốc tách mi và phủ đều màu đen sâu từ gốc đến ngọn mi.',
        'specs': {
          'volume': '8ml',
          'finish': 'Jet Black',
          'features': 'Không thấm nước (Waterproof), không vón cục',
          'brush': 'Cọ xoắn ốc 3D',
          'origin': 'Mỹ',
        },
        'stock': 130,
        'is_active': true,
        'tags': ['best_seller'],
        'rating': 4.7,
        'reviews': 287,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-ESE-BLUSH-CORAL',
        'name': 'Silky Blush Powder - Coral Kiss',
        'brand': 'ESENCE',
        'category': 'makeup',
        'category_id': 'cat_makeup',
        'emoji': '🌸',
        'images': ['https://images.unsplash.com/photo-1583209814683-c023dd293cc6?w=600&q=80'],
        'price': 560000,
        'sale_price': 0,
        'description': 'Phấn má hồng mịn lụa tông Coral Kiss ấm áp, lên màu tự nhiên như từ bên trong. Dễ tán, lâu trôi và không bết dính trong suốt cả ngày.',
        'specs': {
          'weight': '6g',
          'finish': 'Satin mịn',
          'shade': 'Coral Kiss (Cam san hô)',
          'features': 'Phấn khoáng siêu mịn, không gây kích ứng',
          'origin': 'Ý',
        },
        'stock': 85,
        'is_active': true,
        'tags': ['new'],
        'rating': 4.6,
        'reviews': 73,
        'created_at': now,
        'updated_at': now,
      },

      // ── PERFUME (thêm 4) ───────────────────────────────────────────────────
      {
        'sku': 'BGL-AUR-EDT-RB50',
        'name': 'Eau de Toilette - Rose Blanche',
        'brand': 'AURUM',
        'category': 'perfume',
        'category_id': 'cat_perfume',
        'emoji': '🌹',
        'images': ['https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=600&q=80'],
        'price': 1850000,
        'sale_price': 1480000,
        'description': 'Nước hoa nhẹ nhàng hương hoa hồng trắng tinh khôi, kết hợp nốt gỗ tuyết tùng ấm áp. Thích hợp cho những ngày dạo phố hay buổi cà phê nhẹ nhàng.',
        'specs': {
          'volume': '50ml',
          'concentration': 'Eau de Toilette (EDT)',
          'scent_family': 'Floral (Hương hoa)',
          'notes': 'Hương đầu: Lê, Chanh vàng. Hương giữa: Hoa hồng trắng, Mẫu đơn. Hương cuối: Tuyết tùng, Xạ hương',
          'longevity': '4 - 6 giờ',
        },
        'stock': 45,
        'is_active': true,
        'tags': ['best_seller'],
        'rating': 4.8,
        'reviews': 192,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-AUR-EDP-OUD100',
        'name': 'Eau de Parfum - Oud Mystique',
        'brand': 'AURUM',
        'category': 'perfume',
        'category_id': 'cat_perfume',
        'emoji': '🕯️',
        'images': ['https://images.unsplash.com/photo-1563170351-be82bc888aa4?w=600&q=80'],
        'price': 3200000,
        'sale_price': 0,
        'description': 'Nước hoa hương trầm hương (Oud) quý hiếm kết hợp hương hổ phách và vani ấm nồng. Mùi hương đặc trưng phương Đông, sang trọng và lâu phai.',
        'specs': {
          'volume': '100ml',
          'concentration': 'Eau de Parfum (EDP)',
          'scent_family': 'Oriental Woody (Hương gỗ phương Đông)',
          'notes': 'Hương đầu: Nghệ tây, Hồ tiêu đen. Hương giữa: Trầm hương Oud, Hoa hồng Thổ Nhĩ Kỳ. Hương cuối: Hổ phách, Vani, Xạ hương trắng',
          'longevity': '8 - 12 giờ',
        },
        'stock': 20,
        'is_active': true,
        'tags': ['new'],
        'rating': 4.9,
        'reviews': 64,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-LUM-EDP-FRESH30',
        'name': 'Fresh Aqua Cologne - Ocean Breeze',
        'brand': 'LUMIÈRE',
        'category': 'perfume',
        'category_id': 'cat_perfume',
        'emoji': '🌊',
        'images': ['https://images.unsplash.com/photo-1541643600914-78b084683702?w=600&q=80'],
        'price': 1200000,
        'sale_price': 980000,
        'description': 'Nước hoa tươi mát hương biển và gió đại dương, năng động và trẻ trung. Phù hợp cho những ngày năng động, dã ngoại hay vận động ngoài trời.',
        'specs': {
          'volume': '75ml',
          'concentration': 'Eau de Cologne (EDC)',
          'scent_family': 'Aquatic Fresh (Hương nước tươi mát)',
          'notes': 'Hương đầu: Chanh xanh, Bạc hà. Hương giữa: Dưa hấu biển, Hoa nhài. Hương cuối: Gỗ trắng, Rêu biển',
          'longevity': '3 - 5 giờ',
        },
        'stock': 60,
        'is_active': true,
        'tags': ['best_seller'],
        'rating': 4.7,
        'reviews': 143,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-PUR-EDP-CHERRY50',
        'name': 'Eau de Parfum - Cherry Blossom',
        'brand': 'PURE',
        'category': 'perfume',
        'category_id': 'cat_perfume',
        'emoji': '🌸',
        'images': ['https://images.unsplash.com/photo-1587017539504-67cfbddac569?w=600&q=80'],
        'price': 1650000,
        'sale_price': 0,
        'description': 'Nước hoa dịu dàng hương hoa anh đào Nhật Bản, nhẹ nhàng và trong trẻo như buổi sáng mùa xuân. Thích hợp cho phụ nữ yêu thích sự tinh tế và thanh lịch.',
        'specs': {
          'volume': '50ml',
          'concentration': 'Eau de Parfum (EDP)',
          'scent_family': 'Floral Fruity (Hoa & Trái cây)',
          'notes': 'Hương đầu: Cherry, Hồng đào. Hương giữa: Hoa anh đào, Hoa mộc lan. Hương cuối: Vani nhẹ, Xạ hương trắng',
          'longevity': '5 - 7 giờ',
        },
        'stock': 55,
        'is_active': true,
        'tags': ['new', 'best_seller'],
        'rating': 4.8,
        'reviews': 108,
        'created_at': now,
        'updated_at': now,
      },

      // ── ACCESSORIES (thêm 4) ───────────────────────────────────────────────
      {
        'sku': 'BGL-ART-MIRROR-LED',
        'name': 'LED Makeup Mirror - Rose Gold',
        'brand': 'ARTISTRY',
        'category': 'accessories',
        'category_id': 'cat_accessories',
        'emoji': '🪞',
        'images': ['https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600&q=80'],
        'price': 780000,
        'sale_price': 650000,
        'description': 'Gương trang điểm đèn LED 3 chế độ ánh sáng (ban ngày/ban đêm/ánh đèn vàng) viền Rose Gold sang trọng, có thể điều chỉnh góc 360° và phóng to 10x.',
        'specs': {
          'size': 'Đường kính 20cm',
          'magnification': '1x và 10x',
          'lighting': '3 chế độ: Daylight, Warm, Natural',
          'power': 'USB-C hoặc pin AA',
          'material': 'Hợp kim nhôm cao cấp',
        },
        'stock': 40,
        'is_active': true,
        'tags': ['best_seller', 'new'],
        'rating': 4.8,
        'reviews': 167,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-PUR-ORGANIZER-PINK',
        'name': 'Acrylic Makeup Organizer - Clear Pink',
        'brand': 'PURE',
        'category': 'accessories',
        'category_id': 'cat_accessories',
        'emoji': '💝',
        'images': ['https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=600&q=80'],
        'price': 450000,
        'sale_price': 0,
        'description': 'Khay đựng mỹ phẩm acrylic trong suốt màu hồng pastel với 12 ngăn đa dạng, giúp sắp xếp son, phấn, cọ và skincare gọn gàng và dễ lấy.',
        'specs': {
          'size': '25 x 18 x 12cm',
          'compartments': '12 ngăn đa kích thước',
          'material': 'Acrylic cao cấp không BPA',
          'color': 'Trong suốt hồng pastel',
          'features': 'Chống trượt, dễ vệ sinh',
        },
        'stock': 70,
        'is_active': true,
        'tags': ['new'],
        'rating': 4.6,
        'reviews': 89,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-ART-SPONGE-SET',
        'name': 'Beauty Blender Sponge Set (3 pcs)',
        'brand': 'ARTISTRY',
        'category': 'accessories',
        'category_id': 'cat_accessories',
        'emoji': '🫧',
        'images': ['https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&q=80'],
        'price': 280000,
        'sale_price': 220000,
        'description': 'Bộ 3 mút tán nền beauty blender chất liệu foam siêu mềm, không thấm nhiều sản phẩm, tán đều kem nền và phấn phủ mịn màng không vệt.',
        'specs': {
          'quantity': '3 miếng (Trứng lớn + Giọt nước + Hình quả tim)',
          'material': 'Latex-free Hydrophilic Foam',
          'usage': 'Làm ẩm trước khi dùng để đạt hiệu quả tốt nhất',
          'clean': 'Rửa bằng xà phòng nhẹ sau mỗi lần dùng',
          'features': 'Không latex, an toàn cho da nhạy cảm',
        },
        'stock': 110,
        'is_active': true,
        'tags': ['best_seller'],
        'rating': 4.7,
        'reviews': 321,
        'created_at': now,
        'updated_at': now,
      },
      {
        'sku': 'BGL-LUM-HEADBAND-SPA',
        'name': 'Spa Headband & Wrist Towel Set',
        'brand': 'LUMIÈRE',
        'category': 'accessories',
        'category_id': 'cat_accessories',
        'emoji': '🎀',
        'images': ['https://images.unsplash.com/photo-1599305090598-fe179d501227?w=600&q=80'],
        'price': 195000,
        'sale_price': 0,
        'description': 'Bộ băng đô spa và khăn cổ tay siêu mềm, thấm hút tốt, dùng khi rửa mặt, đắp mặt nạ hoặc làm skincare. Chất liệu bông tự nhiên dịu nhẹ với làn da.',
        'specs': {
          'includes': '1 băng đô + 2 khăn cổ tay',
          'material': '100% Cotton tự nhiên',
          'color': 'Hồng pastel / Trắng kem',
          'features': 'Co giãn tốt, giữ tóc gọn trong khi skincare',
          'care': 'Giặt máy ở nhiệt độ thường',
        },
        'stock': 180,
        'is_active': true,
        'tags': ['new'],
        'rating': 4.5,
        'reviews': 54,
        'created_at': now,
        'updated_at': now,
      },
    ];

    for (var prod in products) {
      final ref = _db.collection('products').doc();
      batch.set(ref, prod);
    }

    await batch.commit();
  }
}
