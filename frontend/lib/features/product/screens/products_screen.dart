import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_mobileshop/features/product/providers/product_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/features/product/widgets/product_card.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sản phẩm',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _buildSearchBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildUnifiedFilterRow(provider),
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
                child: Center(
                  child: Text(
                    'Không có sản phẩm',
                    style: TextStyle(fontFamily: 'DM Sans'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.60, // slightly adjusted ratio to match custom ProductCard layout
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(product: products[index]),
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
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

  Widget _buildUnifiedFilterRow(ProductProvider provider) {
    final categories = <Map<String, dynamic>>[
      {'id': null, 'name': 'Tất cả', 'slug': null},
      ...provider.categories,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...categories.map((category) {
                    final slug = category['slug'] as String?;
                    final selected = provider.selectedCategory == slug;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => provider.filterByCategory(slug),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.15),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category['name']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  color: selected ? Colors.white : AppColors.primary,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  _filterChip(
                    provider.selectedBrand ?? 'Thương hiệu',
                    Icons.arrow_drop_down,
                    provider.selectedBrand != null,
                    () => _showBrandFilterSheet(context, provider),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    _getPriceRangeLabel(provider.selectedPriceRange),
                    Icons.arrow_drop_down,
                    provider.selectedPriceRange != null,
                    () => _showPriceRangeFilterSheet(context, provider),
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    _getSortLabel(provider.sortBy),
                    Icons.filter_list,
                    provider.sortBy != null,
                    () => _showSortFilterSheet(context, provider),
                  ),
                  if (provider.selectedBrand != null ||
                      provider.selectedPriceRange != null ||
                      provider.sortBy != null) ...[
                    const SizedBox(width: 8),
                    _filterChip(
                      'Xóa bộ lọc',
                      Icons.close,
                      false,
                      () => provider.resetFilters(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view_rounded,
                color: AppColors.onSurfaceVariant),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  String _getPriceRangeLabel(String? range) {
    if (range == 'under_500k') return 'Dưới 500k';
    if (range == '500k_1m') return '500k - 1M';
    if (range == 'over_1m') return 'Trên 1M';
    return 'Khoảng giá';
  }

  String _getSortLabel(String? sort) {
    if (sort == 'price_asc') return 'Giá tăng dần';
    if (sort == 'price_desc') return 'Giá giảm dần';
    return 'Lọc';
  }

  void _showBrandFilterSheet(BuildContext context, ProductProvider provider) {
    final brands = provider.availableBrands;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn thương hiệu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('Tất cả thương hiệu', style: TextStyle(fontFamily: 'DM Sans')),
                      trailing: provider.selectedBrand == null
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        provider.setBrand(null);
                        Navigator.pop(context);
                      },
                    ),
                    ...brands.map((brand) => ListTile(
                          title: Text(brand, style: const TextStyle(fontFamily: 'DM Sans')),
                          trailing: provider.selectedBrand == brand
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () {
                            provider.setBrand(brand);
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPriceRangeFilterSheet(BuildContext context, ProductProvider provider) {
    final ranges = [
      {'label': 'Tất cả khoảng giá', 'value': null},
      {'label': 'Dưới 500.000đ', 'value': 'under_500k'},
      {'label': '500.000đ - 1.000.000đ', 'value': '500k_1m'},
      {'label': 'Trên 1.000.000đ', 'value': 'over_1m'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn khoảng giá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ...ranges.map((r) => ListTile(
                    title: Text(r['label'] as String, style: const TextStyle(fontFamily: 'DM Sans')),
                    trailing: provider.selectedPriceRange == r['value']
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      provider.setPriceRange(r['value'] as String?);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showSortFilterSheet(BuildContext context, ProductProvider provider) {
    final sortOptions = [
      {'label': 'Mới nhất', 'value': null},
      {'label': 'Giá tăng dần (Thấp đến Cao)', 'value': 'price_asc'},
      {'label': 'Giá giảm dần (Cao đến Thấp)', 'value': 'price_desc'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sắp xếp theo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Sans',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ...sortOptions.map((s) => ListTile(
                    title: Text(s['label'] as String, style: const TextStyle(fontFamily: 'DM Sans')),
                    trailing: provider.sortBy == s['value']
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      provider.setSortBy(s['value'] as String?);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
