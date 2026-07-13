import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_toast.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    // Safely extract price and originalPrice/salePrice from Firestore schema
    final num priceVal = p['price'] ?? 0;
    final num salePriceVal = p['sale_price'] ?? 0;

    // If sale_price is > 0 and less than price, we have a discount
    final bool hasDiscount = salePriceVal > 0 && salePriceVal < priceVal;
    final int displayPrice = (hasDiscount ? salePriceVal : priceVal).toInt();
    final int? displayOriginalPrice = hasDiscount ? priceVal.toInt() : null;

    final String name = p['name'] ?? 'Sản phẩm';
    final String brand = p['brand'] ?? 'Beauty & Glow';
    final String description = p['description'] ?? 'Không có mô tả sản phẩm.';
    final double rating = (p['rating'] ?? 4.8).toDouble();
    final int reviews = (p['reviews'] ?? 12).toInt();

    // Spec details map
    final Map<String, dynamic> specs = p['specs'] is Map ? p['specs'] as Map<String, dynamic> : {};

    // Resolve image emoji representation safely
    String emoji = '💄';
    if (p['emoji'] != null) {
      emoji = p['emoji'] as String;
    } else {
      final category = (p['category'] ?? '').toString().toLowerCase();
      final nameLower = name.toLowerCase();
      if (category.contains('skincare') || nameLower.contains('serum') || nameLower.contains('toner') || nameLower.contains('kem dưỡng')) {
        emoji = '🧴';
      } else if (category.contains('makeup') || nameLower.contains('son') || nameLower.contains('phấn') || nameLower.contains('mascara')) {
        emoji = '💄';
      } else if (category.contains('perfume') || nameLower.contains('nước hoa')) {
        emoji = '🌸';
      } else if (category.contains('cleanser') || nameLower.contains('rửa mặt') || nameLower.contains('tẩy trang')) {
        emoji = '🫧';
      } else if (nameLower.contains('mask') || nameLower.contains('mặt nạ')) {
        emoji = '🎭';
      } else {
        emoji = '✨';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? AppColors.primary : AppColors.onSurface,
            ),
            onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Emoji Display Container
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: _buildProductImage(p, emoji, 120),
            ),
            const SizedBox(height: 24),

            // Product Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      brand.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1.0,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Rating Row
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFBC02D), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$rating',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($reviews đánh giá)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Chính hãng',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatPrice(displayPrice)}đ',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (hasDiscount && displayOriginalPrice != null) ...[
                        Text(
                          '${_formatPrice(displayOriginalPrice)}đ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${(((displayOriginalPrice - displayPrice) / displayOriginalPrice) * 100).round()}%',
                            style: const TextStyle(
                              color: AppColors.onErrorContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cosmetics info fields
                  _buildCosmeticsInfo(p),

                  // Reviews section
                  _ReviewsSection(productId: p['id'] as String? ?? ''),

                  // Specs
                  if (specs.isNotEmpty) ...[
                    const Text(
                      'Thông tin chi tiết',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Column(
                        children: specs.entries.map((entry) {
                          String label = entry.key;
                          if (label == 'ingredients') label = 'Thành phần';
                          else if (label == 'skin_type') label = 'Loại da phù hợp';
                          else if (label == 'volume') label = 'Dung tích';
                          else if (label == 'how_to_use') label = 'Hướng dẫn dùng';
                          else if (label == 'origin') label = 'Xuất xứ';
                          else if (label == 'expiry') label = 'Hạn sử dụng';
                          else if (label == 'screen') label = 'Màn hình';
                          else if (label == 'cpu') label = 'Vi xử lý';
                          else if (label == 'ram') label = 'Bộ nhớ RAM';
                          else if (label == 'rom') label = 'Bộ nhớ trong';
                          else if (label == 'battery') label = 'Dung lượng Pin';
                          else if (label == 'camera') label = 'Hệ thống Camera';
                          else if (label == 'connection') label = 'Kết nối';
                          else if (label == 'features') label = 'Tính năng nổi bật';

                          final isLast = entry.key == specs.keys.last;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 13,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value.toString(),
                                        style: const TextStyle(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          fontFamily: 'DM Sans',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) const Divider(height: 0, indent: 16, endIndent: 16, color: AppColors.outlineVariant),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
              top: BorderSide(color: AppColors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Add to Cart button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<CartProvider>().addItem(p, quantity: _quantity);
                      CustomToast.showSuccess(
                        context,
                        'Đã thêm $_quantity x $name vào giỏ hàng.',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Thêm vào giỏ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Buy now button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartProvider>().addItem(p, quantity: _quantity);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Mua ngay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCosmeticsInfo(Map<String, dynamic> p) {
    final skinType = p['skin_type'] as String?;
    final ingredients = p['ingredients'] as String?;
    final volume = p['volume'] as String?;
    final howToUse = p['how_to_use'] as String?;
    final origin = p['origin'] as String?;

    final rows = <Map<String, String>>[];
    if (volume != null && volume.isNotEmpty) rows.add({'label': 'Dung tích', 'value': volume, 'icon': '📦'});
    if (skinType != null && skinType.isNotEmpty) rows.add({'label': 'Loại da phù hợp', 'value': skinType, 'icon': '🌿'});
    if (origin != null && origin.isNotEmpty) rows.add({'label': 'Xuất xứ', 'value': origin, 'icon': '🌍'});

    if (rows.isEmpty && ingredients == null && howToUse == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rows.isNotEmpty) ...[
          const Text(
            'Thông tin sản phẩm',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface, fontFamily: 'DM Sans'),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: rows.asMap().entries.map((e) {
                final isLast = e.key == rows.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(e.value['icon']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 130,
                            child: Text(e.value['label']!, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, fontSize: 13, fontFamily: 'DM Sans')),
                          ),
                          Expanded(
                            child: Text(e.value['value']!, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500, fontSize: 13, fontFamily: 'DM Sans')),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) const Divider(height: 0, indent: 16, endIndent: 16, color: AppColors.outlineVariant),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (skinType != null && skinType.isNotEmpty) ...[
          const Text('Loại da phù hợp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface, fontFamily: 'DM Sans')),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skinType.split(',').map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: AppColors.primaryFixed, borderRadius: BorderRadius.circular(20)),
              child: Text(s.trim(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'DM Sans')),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (howToUse != null && howToUse.isNotEmpty) ...[
          const Text('Hướng dẫn sử dụng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface, fontFamily: 'DM Sans')),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade100)),
            child: Text(howToUse, style: const TextStyle(fontSize: 13, color: AppColors.onSurface, height: 1.5, fontFamily: 'DM Sans')),
          ),
          const SizedBox(height: 24),
        ],
        if (ingredients != null && ingredients.isNotEmpty) ...[
          const Text('Thành phần chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface, fontFamily: 'DM Sans')),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.outlineVariant)),
            child: Text(ingredients, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5, fontFamily: 'DM Sans')),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildProductImage(Map<String, dynamic> p, String emoji, double emojiSize) {
    final images = p['images'];
    String? imageUrl;
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    } else if (p['image_url'] != null) {
      imageUrl = p['image_url'].toString();
    }

    if (imageUrl != null && imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: emojiSize),
              ),
            );
          },
        ),
      );
    }
    return Center(
      child: Text(
        emoji,
        style: TextStyle(fontSize: emojiSize),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}

/// Section hiển thị danh sách đánh giá của sản phẩm từ Firestore.
class _ReviewsSection extends StatelessWidget {
  final String productId;

  const _ReviewsSection({required this.productId});

  @override
  Widget build(BuildContext context) {
    if (productId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('product_id', isEqualTo: productId)
          .orderBy('created_at', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Đánh giá sản phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const Spacer(),
                if (docs.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFBC02D), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _avgStars(docs).toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF795548),
                          ),
                        ),
                        Text(
                          ' (${docs.length})',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (docs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text('💬', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có đánh giá nào.\nHãy là người đầu tiên đánh giá!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...docs.map((doc) => _ReviewCard(data: doc.data() as Map<String, dynamic>)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  double _avgStars(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return 0;
    final total = docs.fold<int>(
        0, (sum, d) => sum + ((d.data() as Map)['stars'] as int? ?? 5));
    return total / docs.length;
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ReviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final userName = data['user_name'] as String? ?? 'Khách hàng';
    final stars = data['stars'] as int? ?? 5;
    final comment = data['comment'] as String? ?? '';
    final createdAt = (data['created_at'] as Timestamp?)?.toDate();
    final dateStr = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryFixed,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'K',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFFBC02D),
                            size: 14,
                          ),
                        ),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
