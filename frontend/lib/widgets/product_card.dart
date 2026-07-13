import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/product_detail_screen.dart';
import '../theme/app_theme.dart';
import 'custom_toast.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final p = widget.product;
    final productId = p['id']?.toString() ?? '';
    final bool isWishlisted = favoritesProvider.isFavorite(productId);

    // Safely extract price and originalPrice/salePrice from Firestore schema
    final num priceVal = p['price'] ?? 0;
    final num salePriceVal = p['sale_price'] ?? 0;

    // If sale_price is > 0 and less than price, we have a discount
    final bool hasDiscount = salePriceVal > 0 && salePriceVal < priceVal;
    final int displayPrice = (hasDiscount ? salePriceVal : priceVal).toInt();
    final int? displayOriginalPrice = hasDiscount ? priceVal.toInt() : null;

    final String name = p['name'] ?? 'Sản phẩm';
    final String brand = p['brand'] ?? 'Beauty & Glow';
    
    // Safely parse double and int
    final double rating = (p['rating'] ?? 4.8).toDouble();
    final int reviews = (p['reviews'] ?? 12).toInt();

    // Resolve tag from tag string or tags list
    String? displayTag;
    if (p['tag'] != null) {
      displayTag = p['tag'] as String;
    } else if (p['tags'] is List && (p['tags'] as List).isNotEmpty) {
      displayTag = (p['tags'] as List).first.toString();
    }

    // Resolve image emoji representation safely
    String emoji = '✨';
    if (p['emoji'] != null) {
      emoji = p['emoji'] as String;
    } else {
      final category = (p['category'] ?? '').toString().toLowerCase();
      final nameLower = name.toLowerCase();
      if (category.contains('skincare') || category.contains('makeup') || category.contains('perfume') || category.contains('hair')) {
        if (category.contains('skincare')) {
          emoji = '🧴';
        } else if (category.contains('makeup')) {
          emoji = '💄';
        } else if (category.contains('perfume')) {
          emoji = '🛍️';
        } else {
          emoji = '🧼';
        }
      } else {
        if (nameLower.contains('tai nghe') || nameLower.contains('headphone') || category.contains('audio')) {
          emoji = '🎧';
        } else if (nameLower.contains('cáp') || nameLower.contains('sạc') || nameLower.contains('charger') || category.contains('accessory')) {
          emoji = '🔌';
        } else if (nameLower.contains('đồng hồ') || nameLower.contains('watch') || category.contains('wearable')) {
          emoji = '⌚';
        } else if (nameLower.contains('ipad') || nameLower.contains('tablet') || nameLower.contains('máy tính bảng')) {
          emoji = '📟';
        } else {
          emoji = '✨'; // Default sparkles
        }
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: p),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: _buildProductImage(p, emoji, 56),
                  ),
                  if (displayTag != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayTag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        context.read<FavoritesProvider>().toggleFavorite(p);
                        final name = p['name'] ?? 'Sản phẩm';
                        final isNowFav = context.read<FavoritesProvider>().isFavorite(productId);
                        CustomToast.showSuccess(
                          context,
                          isNowFav
                              ? 'Đã thêm $name vào danh sách yêu thích.'
                              : 'Đã xóa $name khỏi danh sách yêu thích.',
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isWishlisted ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        fontFamily: 'DM Sans',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFFBC02D)),
                        const SizedBox(width: 2),
                        Text(
                          '$rating',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviews)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_formatPrice(displayPrice)}đ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                            if (hasDiscount && displayOriginalPrice != null)
                              Text(
                                '${_formatPrice(displayOriginalPrice)}đ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<CartProvider>().addItem(p, quantity: 1);
                            CustomToast.showSuccess(
                              context,
                              'Đã thêm $name vào giỏ hàng.',
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
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
