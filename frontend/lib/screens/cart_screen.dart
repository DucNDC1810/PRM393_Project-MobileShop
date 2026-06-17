import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_toast.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _couponCode = '';
  bool _couponApplied = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items;

    final int subtotal = cart.totalAmount;
    final int discount = _couponApplied ? (subtotal * 0.1).round() : 0;
    final int shipping = subtotal > 500000 || subtotal == 0 ? 0 : 30000;
    final int total = subtotal - discount + shipping;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Giỏ hàng (${cartItems.length})',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => cart.clear(),
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: AppColors.error, fontSize: 13, fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty 
          ? _buildEmptyCart() 
          : _buildCartContent(cart, cartItems, subtotal, discount, shipping, total),
      bottomNavigationBar: cartItems.isEmpty 
          ? null 
          : _buildCheckoutBar(cart, cartItems, subtotal, discount, shipping, total),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm sản phẩm yêu thích vào giỏ hàng',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Switch to products tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text(
              'Mua sắm ngay',
              style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    CartProvider cart, 
    List<Map<String, dynamic>> cartItems, 
    int subtotal, 
    int discount, 
    int shipping, 
    int total,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cartItems.map((item) => _buildCartItem(cart, item)),
          const SizedBox(height: 16),
          _buildCouponSection(discount),
          const SizedBox(height: 16),
          _buildOrderSummary(subtotal, discount, shipping, total),
          if (shipping == 0 && subtotal > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_shipping, color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Bạn được miễn phí vận chuyển!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItem(CartProvider cart, Map<String, dynamic> item) {
    final String id = item['id'] as String;
    final int itemPrice = item['price'] as int;
    final int itemQuantity = item['quantity'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildCartItemImage(item),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['brand'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    fontFamily: 'DM Sans',
                  ),
                ),
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatPrice(itemPrice * itemQuantity)}đ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    Row(
                      children: [
                        _quantityButton(
                          Icons.remove,
                          () => cart.updateQuantity(id, itemQuantity - 1),
                        ),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text(
                            '$itemQuantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                        _quantityButton(
                          Icons.add,
                          () => cart.updateQuantity(id, itemQuantity + 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCouponSection(int discount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mã giảm giá',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() {
                    _couponCode = v;
                    _couponApplied = false;
                  }),
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá...',
                    hintStyle: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 13, fontFamily: 'DM Sans'),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _couponApplied
                            ? AppColors.success
                            : AppColors.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    suffixIcon: _couponApplied
                        ? const Icon(Icons.check_circle,
                            color: AppColors.success, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _couponCode.isNotEmpty
                    ? () => setState(() => _couponApplied = true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Áp dụng',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
              ),
            ],
          ),
          if (_couponApplied)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Mã giảm giá đã được áp dụng! Tiết kiệm ${_formatPrice(discount)}đ',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(int subtotal, int discount, int shipping, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Tạm tính', subtotal),
          if (_couponApplied) _summaryRow('Giảm giá (10%)', -discount, isDiscount: true),
          _summaryRow('Vận chuyển', shipping, isFree: shipping == 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  fontFamily: 'DM Sans',
                ),
              ),
              Text(
                '${_formatPrice(total)}đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int amount,
      {bool isDiscount = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'DM Sans',
            ),
          ),
          isFree
              ? const Text(
                  'Miễn phí',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                  ),
                )
              : Text(
                  '${isDiscount ? '-' : ''}${_formatPrice(amount.abs())}đ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDiscount ? AppColors.success : AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(
    CartProvider cart, 
    List<Map<String, dynamic>> cartItems, 
    int subtotal, 
    int discount, 
    int shipping, 
    int total,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              if (!auth.isLoggedIn) {
                CustomToast.showError(
                  context,
                  'Vui lòng đăng nhập để thực hiện thanh toán.',
                );
                return;
              }

              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final user = auth.user;
                final itemsData = cartItems.map((item) => {
                  'id': item['id'],
                  'name': item['name'],
                  'brand': item['brand'],
                  'price': item['price'],
                  'quantity': item['quantity'],
                  'emoji': item['emoji'],
                  'images': item['images'],
                  'image_url': item['image_url'],
                }).toList();

                await FirebaseFirestore.instance.collection('orders').add({
                  'user_email': user?.email,
                  'user_uid': user?.uid,
                  'items': itemsData,
                  'subtotal': subtotal,
                  'discount': discount,
                  'shipping': shipping,
                  'total': total,
                  'status': 'Chờ xử lý',
                  'created_at': FieldValue.serverTimestamp(),
                });

                // Dismiss loading
                if (mounted) Navigator.of(context).pop();

                // Clear cart
                cart.clear();

                // Show success dialog
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('🎉 Đặt hàng thành công!', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
                      content: const Text(
                        'Đơn hàng của bạn đã được tiếp nhận và đang được xử lý. Cảm ơn bạn đã mua sắm tại Beauty & Glow!',
                        style: TextStyle(fontFamily: 'DM Sans'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Đóng', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'DM Sans')),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                // Dismiss loading
                if (mounted) Navigator.of(context).pop();
                
                if (mounted) {
                  CustomToast.showError(
                    context,
                    'Đã có lỗi xảy ra: $e',
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_formatPrice(total)}đ',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'DM Sans'),
                ),
              ],
            ),
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

  Widget _buildCartItemImage(Map<String, dynamic> item) {
    final images = item['images'];
    String? imageUrl;
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    } else if (item['image_url'] != null) {
      imageUrl = item['image_url'].toString();
    }
    final emoji = item['emoji'] as String? ?? '✨';

    if (imageUrl != null && imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            );
          },
        ),
      );
    }
    return Center(
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}
