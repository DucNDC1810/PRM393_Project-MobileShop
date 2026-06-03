import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isGridView = true;
  String _sortBy = 'popular';

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Kem dưỡng ẩm Rose Glow',
      'brand': 'Luminous Bloom',
      'price': 450000,
      'originalPrice': 590000,
      'rating': 4.8,
      'reviews': 234,
      'emoji': '🌹',
      'tag': 'Bán chạy',
    },
    {
      'name': 'Son môi Velvet Bloom',
      'brand': 'Beauty & Glow',
      'price': 285000,
      'originalPrice': null,
      'rating': 4.6,
      'reviews': 128,
      'emoji': '💄',
      'tag': 'Mới',
    },
    {
      'name': 'Serum vitamin C sáng da',
      'brand': 'Glow Lab',
      'price': 620000,
      'originalPrice': 780000,
      'rating': 4.9,
      'reviews': 512,
      'emoji': '✨',
      'tag': '-20%',
    },
    {
      'name': 'Kem chống nắng SPF50+',
      'brand': 'Skin Shield',
      'price': 320000,
      'originalPrice': null,
      'rating': 4.7,
      'reviews': 89,
      'emoji': '☀️',
      'tag': null,
    },
    {
      'name': 'Toner Hoa Hồng',
      'brand': 'Rose Beauty',
      'price': 195000,
      'originalPrice': null,
      'rating': 4.5,
      'reviews': 67,
      'emoji': '🌸',
      'tag': null,
    },
    {
      'name': 'Mask ngủ dưỡng ẩm',
      'brand': 'Glow Lab',
      'price': 240000,
      'originalPrice': 290000,
      'rating': 4.4,
      'reviews': 43,
      'emoji': '🫧',
      'tag': '-17%',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sản phẩm',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.primary,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortBar(),
          Expanded(
            child: _isGridView ? _buildGrid() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          Text(
            '${_products.length} sản phẩm',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _getSortLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'popular':
        return 'Phổ biến';
      case 'price_asc':
        return 'Giá tăng';
      case 'price_desc':
        return 'Giá giảm';
      case 'rating':
        return 'Đánh giá';
      default:
        return 'Mới nhất';
    }
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) => ProductCard(product: _products[index]),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = _products[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(p['emoji'] as String,
                      style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['brand'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      p['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFFBC02D)),
                        Text(' ${p['rating']} (${p['reviews']})',
                            style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_formatPrice(p['price'] as int)}đ',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (p['originalPrice'] != null)
                              Text(
                                '${_formatPrice(p['originalPrice'] as int)}đ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sắp xếp theo',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              ('popular', 'Phổ biến nhất'),
              ('newest', 'Mới nhất'),
              ('price_asc', 'Giá tăng dần'),
              ('price_desc', 'Giá giảm dần'),
              ('rating', 'Đánh giá cao nhất'),
            ].map(
              (item) => RadioListTile<String>(
                value: item.$1,
                groupValue: _sortBy,
                title: Text(item.$2),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  setState(() => _sortBy = v!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bộ lọc',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Xóa tất cả',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Khoảng giá',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              RangeSlider(
                values: RangeValues(0, 800000),
                min: 0,
                max: 2000000,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.outlineVariant,
                onChanged: null,
              ),
              const SizedBox(height: 16),
              const Text('Đánh giá',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              ...List.generate(
                5,
                (i) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5 - i,
                      (_) => const Icon(Icons.star,
                          color: Color(0xFFFBC02D), size: 16),
                    ),
                  ),
                  title: Text('${5 - i} sao trở lên',
                      style: const TextStyle(fontSize: 13)),
                  trailing: Checkbox(
                    value: false,
                    activeColor: AppColors.primary,
                    onChanged: (_) {},
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Áp dụng bộ lọc',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
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
