import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _didLoadInitialData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didLoadInitialData) return;
    _didLoadInitialData = true;

    _searchController.addListener(() {
      if (!mounted) return;
      setState(() => _searchQuery = _searchController.text.trim());
    });

    final provider = context.read<ProductProvider>();
    provider.loadProducts();
    provider.loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = _filterProducts(provider.products);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadProducts(category: provider.selectedCategory);
          await provider.loadCategories();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildSearchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildCategories(provider),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    _filterChip('Thương hiệu', Icons.arrow_drop_down),
                    const SizedBox(width: 12),
                    _filterChip('Khoảng giá', Icons.arrow_drop_down),
                    const SizedBox(width: 12),
                    _filterChip('Lọc', Icons.filter_list),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.grid_view_rounded,
                          color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.status == LoadStatus.error)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Lỗi: ${provider.error ?? 'Không thể tải sản phẩm'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              )
            else if (products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Không có sản phẩm')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductCard(product: products[index]),
                    childCount: products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterProducts(List<Map<String, dynamic>> products) {
    if (_searchQuery.isEmpty) return products;

    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final brand = (product['brand'] ?? '').toString().toLowerCase();
      return name.contains(query) || brand.contains(query);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEA),
        borderRadius: BorderRadius.circular(24),
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
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(Icons.cancel_outlined,
                  color: AppColors.outline, size: 20),
            )
          else
            const Icon(Icons.mic_none,
                color: AppColors.onSurfaceVariant, size: 22),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildCategories(ProductProvider provider) {
    final categories = <Map<String, dynamic>>[
      {'id': null, 'name': 'Tất cả', 'slug': null},
      ...provider.categories,
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final slug = category['slug'] as String?;
          final selected = provider.selectedCategory == slug;
          return GestureDetector(
            onTap: () => provider.filterByCategory(slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.primary),
              ),
              child: Center(
                child: Text(
                  category['name']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : AppColors.primary,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = (product['name'] ?? '').toString();
    final brand = (product['brand'] ?? '').toString();
    final images = (product['images'] as List?)?.whereType<String>().toList() ?? const [];
    final price = (product['price'] as num?)?.toInt() ?? 0;
    final salePrice = (product['sale_price'] as num?)?.toInt() ?? 0;
    final stock = (product['stock'] as num?)?.toInt() ?? 0;
    final inStock = stock > 0;
    final hasSale = salePrice > 0;
    final displayPrice = hasSale ? salePrice : price;
    final discountPercent = hasSale && price > 0
        ? (((price - salePrice) / price) * 100).round()
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFFF8F1F4)),
                if (images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: images.first,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const Center(
                      child: Icon(Icons.image, size: 40),
                    ),
                  )
                else
                  const Center(child: Icon(Icons.image, size: 40)),
                if (!inStock)
                  Container(
                    color: Colors.black.withValues(alpha: 0.38),
                    child: const Center(
                      child: Text(
                        'Hết hàng',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (discountPercent != null && inStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8547A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatPrice(displayPrice)}đ',
                  style: const TextStyle(
                    color: Color(0xFFE8547A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }
}
