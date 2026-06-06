import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Vui lòng đăng nhập để xem lịch sử đơn hàng.',
                style: TextStyle(fontFamily: 'DM Sans'),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('user_email', isEqualTo: user.email)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Lỗi: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'DM Sans', color: AppColors.error),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📦', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có đơn hàng nào',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Đơn hàng bạn đặt sẽ xuất hiện tại đây.',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final orderDoc = docs[index];
                    final order = orderDoc.data() as Map<String, dynamic>;
                    final orderId = orderDoc.id.substring(0, 8).toUpperCase();
                    final items = order['items'] as List? ?? [];
                    final subtotal = (order['subtotal'] ?? 0) as num;
                    final total = (order['total'] ?? 0) as num;
                    final status = order['status'] ?? 'Chờ xử lý';

                    // Parse timestamp
                    final createdAt = order['created_at'] as Timestamp?;
                    final dateStr = createdAt != null
                        ? _formatDate(createdAt.toDate())
                        : 'Vừa xong';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (ID + Status)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MÃ ĐƠN: #$orderId',
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              _statusBadge(status),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.outlineVariant),
                          ),

                          // Items List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final item = items[idx] as Map<String, dynamic>;
                              final String emoji = item['emoji'] ?? '📱';
                              final String name = item['name'] ?? 'Sản phẩm';
                              final int qty = (item['quantity'] ?? 1) as int;
                              final int price = (item['price'] ?? 0) as int;

                              return Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppColors.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Số lượng: $qty  •  Đơn giá: ${_formatPrice(price)}đ',
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
                              );
                            },
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.outlineVariant),
                          ),

                          // Footer (Total amount + action buttons)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng cộng (${items.length} món):',
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${_formatPrice(total.toInt())}đ',
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Action
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: const Text(
                                    'Liên hệ hỗ trợ',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Theo dõi đơn hàng',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFF92400E);

    if (status == 'Đang giao') {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFF9A3412);
    } else if (status == 'Hoàn thành') {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
