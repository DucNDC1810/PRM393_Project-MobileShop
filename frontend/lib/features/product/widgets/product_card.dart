import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/core/utils/format_utils.dart';
import 'package:project_mobileshop/core/widgets/product_image.dart';
import 'package:project_mobileshop/features/cart/providers/cart_provider.dart';
import 'package:project_mobileshop/features/product/models/product.dart';
import 'package:project_mobileshop/features/product/providers/favorites_provider.dart';
import 'package:project_mobileshop/features/product/screens/product_detail_screen.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/widgets/custom_toast.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final p = product;
    final bool isWishlisted = favoritesProvider.isFavorite(p.id);

    final String? displayTag = p.tags.isNotEmpty ? p.tags.first : null;
    final String emoji = resolveProductEmoji(p.toMap());

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
                    child: ProductImage(
                      product: p.toMap(),
                      emoji: emoji,
                      emojiSize: 56,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
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
                        context.read<FavoritesProvider>().toggleFavorite(p.toMap());
                        final isNowFav = context.read<FavoritesProvider>().isFavorite(p.id);
                        CustomToast.showSuccess(
                          context,
                          isNowFav
                              ? 'Đã thêm ${p.name} vào danh sách yêu thích.'
                              : 'Đã xóa ${p.name} khỏi danh sách yêu thích.',
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
                      p.brand,
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
                      p.name,
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
                          '${p.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${p.reviews})',
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
                              '${formatVnd(p.activePrice)}đ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                            if (p.hasDiscount)
                              Text(
                                '${formatVnd(p.price)}đ',
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
                            context.read<CartProvider>().addItem(p.toMap(), quantity: 1);
                            CustomToast.showSuccess(
                              context,
                              'Đã thêm ${p.name} vào giỏ hàng.',
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
}
