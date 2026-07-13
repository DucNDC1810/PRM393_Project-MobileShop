import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

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
                              final String brand = item['brand'] as String? ?? '';
                              final int qty = (item['quantity'] ?? 1) as int;
                              final int price = (item['price'] ?? 0) as int;

                              final images = item['images'];
                              String? imageUrl;
                              if (images is List && images.isNotEmpty) {
                                imageUrl = images.first?.toString();
                              } else if (item['image_url'] != null) {
                                imageUrl = item['image_url'].toString();
                              }
                              final bool hasImage = imageUrl != null && imageUrl.startsWith('http');

                              return Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.outlineVariant),
                                    ),
                                    child: hasImage
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(9),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, e) => Center(
                                                child: Text(emoji, style: const TextStyle(fontSize: 26)),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(emoji, style: const TextStyle(fontSize: 26)),
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
                                        if (brand.isNotEmpty)
                                          Text(
                                            brand,
                                            style: const TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 11,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        Text(
                                          'x$qty  •  ${_formatPrice(price)}đ',
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          orderInfo: {
                                            'orderId': orderId,
                                            'status': status,
                                            'total': total,
                                            'items': items,
                                            'date': dateStr,
                                          },
                                        ),
                                      ),
                                    );
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
                              if (status.toLowerCase().contains('giao') && status.toLowerCase() != 'hoàn thành') ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _confirmReceived(context, orderDoc.id),
                                    icon: const Icon(Icons.check_circle_outline, size: 16),
                                    label: const Text(
                                      'Đã nhận hàng',
                                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ] else if (status.toLowerCase() != 'hoàn thành') ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _showTrackingDialog(context, status, orderId, dateStr),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Theo dõi đơn',
                                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
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

  void _showTrackingDialog(BuildContext context, String status, String orderId, String dateStr) {
    final steps = [
      {'label': 'Chờ xử lý', 'icon': Icons.hourglass_empty_outlined},
      {'label': 'Đã xác nhận', 'icon': Icons.check_circle_outline},
      {'label': 'Đang giao', 'icon': Icons.local_shipping_outlined},
      {'label': 'Hoàn thành', 'icon': Icons.done_all},
    ];

    final currentIndex = steps.indexWhere((s) => s['label'] == status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Theo dõi đơn #$orderId', style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.onSurface)),
            if (dateStr.isNotEmpty)
              Text(dateStr, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 20),
            ...steps.asMap().entries.map((e) {
              final i = e.key;
              final step = e.value;
              final isDone = currentIndex >= 0 && i <= currentIndex;
              final isCurrent = i == currentIndex;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.primary : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step['icon'] as IconData, size: 18, color: isDone ? Colors.white : Colors.grey),
                      ),
                      if (i < steps.length - 1)
                        Container(width: 2, height: 28, color: i < currentIndex ? AppColors.primary : Colors.grey.shade200),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      step['label'] as String,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? AppColors.primary : isDone ? AppColors.onSurface : Colors.grey,
                      ),
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: const Text('Hiện tại', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
                child: const Text('Đóng', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReceived(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đã nhận hàng', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        content: const Text('Bạn xác nhận đã nhận được hàng và đơn hàng này sẽ được hoàn tất?', style: TextStyle(fontFamily: 'DM Sans')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Xác nhận', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'status': 'Hoàn thành',
        'received_at': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn! Đơn hàng đã được xác nhận hoàn tất.', style: TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.'), backgroundColor: Colors.red),
        );
      }
    }
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
