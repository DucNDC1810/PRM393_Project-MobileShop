import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedCategory = 0;
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'Tất cả',
    'Skincare',
    'Makeup',
    'Perfume',
    'Chăm sóc tóc',
  ];

  final List<_Product> _products = [
    _Product(
      name: 'Innisfree Green Tea Serum',
      price: 250000,
      originalPrice: 350000,
      discount: '-30%',
      emoji: '🍵',
      color: const Color(0xFFE8F5E9),
      outOfStock: false,
      isWishlisted: false,
    ),
    _Product(
      name: "L'Oréal Revitalift Cream",
      price: 450000,
      originalPrice: null,
      discount: null,
      emoji: '💫',
      color: const Color(0xFFFFF3E0),
      outOfStock: false,
      isWishlisted: false,
    ),
    _Product(
      name: 'Laneige Water Sleeping Mask',
      price: 520000,
      originalPrice: 610000,
      discount: '-15%',
      emoji: '💧',
      color: const Color(0xFFE3F2FD),
      outOfStock: false,
      isWishlisted: false,
    ),
    _Product(
      name: 'MAC Studio Fix Powder',
      price: 0,
      originalPrice: null,
      discount: null,
      emoji: '🖤',
      color: const Color(0xFFF5F5F5),
      outOfStock: true,
      isWishlisted: false,
    ),
    _Product(
      name: 'The Face Shop Rice Toner',
      price: 180000,
      originalPrice: 225000,
      discount: '-20%',
      emoji: '🌾',
      color: const Color(0xFFFFFDE7),
      outOfStock: false,
      isWishlisted: true,
    ),
    _Product(
      name: 'Maybelline Foundation',
      price: 270000,
      originalPrice: 300000,
      discount: '-10%',
      emoji: '💄',
      color: const Color(0xFFFCE4EC),
      outOfStock: false,
      isWishlisted: false,
    ),
    _Product(
      name: 'COSRX Snail Essence',
      price: 380000,
      originalPrice: null,
      discount: null,
      emoji: '🐌',
      color: const Color(0xFFF3E5F5),
      outOfStock: false,
      isWishlisted: false,
    ),
    _Product(
      name: 'Sulwhasoo First Care',
      price: 1200000,
      originalPrice: 1600000,
      discount: '-25%',
      emoji: '✨',
      color: const Color(0xFFFFF8E1),
      outOfStock: false,
      isWishlisted: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchDelegate(child: _buildSearchBar()),
          ),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(child: _buildFilterRow()),
          _buildProductGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 56,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.primary),
        onPressed: () {},
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Beauty & Glow',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.local_florist, color: AppColors.primary, size: 18),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
              onPressed: () {},
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── SEARCH BAR ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFEA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                  fontFamily: 'DM Sans',
                ),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm, thương hiệu...',
                  hintStyle: TextStyle(
                    color: AppColors.outline,
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const Icon(Icons.mic_none, color: AppColors.onSurfaceVariant, size: 22),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // ── CATEGORIES ─────────────────────────────────────────────────────────────

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: selected ? Colors.white : AppColors.primary,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── FILTER ROW ─────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          _filterChip('Thương hiệu', Icons.arrow_drop_down),
          const SizedBox(width: 16),
          _filterChip('Khoảng giá', Icons.arrow_drop_down),
          const SizedBox(width: 16),
          _filterChip('Lọc', Icons.filter_list),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.grid_view_rounded,
                color: AppColors.onSurfaceVariant, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(width: 2),
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  // ── PRODUCT GRID ───────────────────────────────────────────────────────────

  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4.6,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _ProductCard(
            product: _products[i],
            onWishlistTap: () =>
                setState(() => _products[i].isWishlisted = !_products[i].isWishlisted),
            onAddTap: () {},
          ),
          childCount: _products.length,
        ),
      ),
    );
  }
}

// ── PRODUCT MODEL ──────────────────────────────────────────────────────────────

class _Product {
  final String name;
  final int price;
  final int? originalPrice;
  final String? discount;
  final String emoji;
  final Color color;
  final bool outOfStock;
  bool isWishlisted;

  _Product({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.emoji,
    required this.color,
    required this.outOfStock,
    required this.isWishlisted,
  });
}

// ── PRODUCT CARD ───────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final _Product product;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddTap;

  const _ProductCard({
    required this.product,
    required this.onWishlistTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14AC254F),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area — 3:4 ratio
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  color: product.outOfStock
                      ? const Color(0xFFF5F5F5)
                      : product.color,
                  child: Opacity(
                    opacity: product.outOfStock ? 0.45 : 1.0,
                    child: ColorFiltered(
                      colorFilter: product.outOfStock
                          ? const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent, BlendMode.color),
                      child: Center(
                        child: Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 62),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Info area
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                          fontFamily: 'DM Sans',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product.outOfStock)
                        Text(
                          'Hết hàng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface.withOpacity(0.45),
                            fontFamily: 'DM Sans',
                          ),
                        )
                      else ...[
                        Text(
                          '${_fmt(product.price)}đ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        if (product.originalPrice != null)
                          Text(
                            '${_fmt(product.originalPrice!)}đ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.outline,
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Out-of-stock overlay
          if (product.outOfStock)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.38),
                child: const Center(
                  child: _OutOfStockBadge(),
                ),
              ),
            ),

          // Discount badge
          if (product.discount != null && !product.outOfStock)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product.discount!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),

          // Wishlist button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: product.outOfStock ? null : onWishlistTap,
              child: Container(
                width: 32,
                height: 32,
                color: Colors.transparent,
                child: Icon(
                  product.isWishlisted ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: product.outOfStock
                      ? Colors.white.withOpacity(0.5)
                      : AppColors.primary,
                ),
              ),
            ),
          ),

          // Add to cart button
          if (!product.outOfStock)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

class _OutOfStockBadge extends StatelessWidget {
  const _OutOfStockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Hết hàng',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}

// ── STICKY SEARCH DELEGATE ─────────────────────────────────────────────────────

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _StickySearchDelegate({required this.child});

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(covariant _StickySearchDelegate old) => old.child != child;
}
