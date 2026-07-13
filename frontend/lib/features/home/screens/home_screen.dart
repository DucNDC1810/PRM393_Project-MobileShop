import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/product/providers/product_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/features/product/widgets/product_card.dart';
import 'package:project_mobileshop/features/home/widgets/category_chip.dart';
import 'package:project_mobileshop/features/home/widgets/promo_banner.dart';
import 'package:project_mobileshop/core/widgets/shop_logo.dart';
import 'package:project_mobileshop/features/product/screens/products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  bool _didInit = false;

  final List<String> _categoryLabels = [
    'Tất cả',
    'Dưỡng da',
    'Trang điểm',
    'Nước hoa',
    'Phụ kiện',
  ];

  final List<String?> _categoryValues = [
    null,
    'skincare',
    'makeup',
    'perfume',
    'accessories',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final provider = context.read<ProductProvider>();
    provider.loadProducts();
    provider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PromoBanner(),
                _buildCategorySection(),
                _buildSectionHeader(
                  'Nổi bật hôm nay',
                  onSeeAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductsScreen()),
                    );
                  },
                ),
                _buildFeaturedGrid(),
                _buildFlashSaleSection(),
                _buildSectionHeader(
                  'Mới nhất',
                  onSeeAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductsScreen()),
                    );
                  },
                ),
                _buildHorizontalProductList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const ShopLogo(size: 32),
          const SizedBox(width: 8),
          const Text(
            'Beauty & Glow',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildSearchBar(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
              SizedBox(width: 8),
              Text(
                'Tìm kiếm sản phẩm...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categoryLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => CategoryChip(
          label: _categoryLabels[index],
          isSelected: _selectedCategoryIndex == index,
          onTap: () {
            setState(() => _selectedCategoryIndex = index);
            context.read<ProductProvider>().filterByCategory(_categoryValues[index]);
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Xem tất cả',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'DM Sans'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGrid() {
    final products = context.watch<ProductProvider>().products;

    if (products.isEmpty) {
      final provider = context.watch<ProductProvider>();
      if (provider.isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            'Chưa có sản phẩm nào.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans'),
          ),
        ),
      );
    }

    final featured = products.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: featured.length,
        itemBuilder: (context, index) => ProductCard(product: featured[index]),
      ),
    );
  }

  Widget _buildFlashSaleSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flash Sale',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Giảm đến 50% • Chỉ trong hôm nay!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  child: const Text('Mua ngay'),
                ),
              ],
            ),
          ),
          const Text('⚡', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList() {
    final products = context.watch<ProductProvider>().products;

    if (products.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Không có sản phẩm mới',
            style: TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    // Filter products with 'new' tag or just take 4
    final newProducts = products.where((p) {
      final tags = p['tags'];
      if (tags is List) {
        return tags.contains('new');
      }
      return false;
    }).toList();

    final displayProducts = newProducts.isNotEmpty 
        ? newProducts 
        : products.reversed.take(4).toList();

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: displayProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = displayProducts[index];
          return SizedBox(
            width: 155,
            child: ProductCard(product: p),
          );
        },
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
