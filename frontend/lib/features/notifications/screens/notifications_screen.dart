import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Track which order doc IDs the user has already read
  final Set<String> _readIds = {};

  // Static promo/tip notifications always shown
  final List<Map<String, dynamic>> _staticNotifs = [
    {
      'id': 'promo_1',
      'title': '⚡ Flash Sale Mỹ Phẩm – Giảm đến 40%!',
      'body': 'Toàn bộ sản phẩm Innisfree, Laneige và The Face Shop giảm giá sốc đến 40%. Nhập mã BEAUTY40 để áp dụng ngay!',
      'type': 'promo',
      'time': '3 giờ trước',
    },
    {
      'id': 'tip_1',
      'title': '🌸 Sản phẩm mới vừa về!',
      'body': 'Bộ dưỡng da Laneige Water Bank Blue Hyaluronic vừa có mặt tại Beauty & Glow. Sản phẩm giữ ẩm chuyên sâu cho mọi loại da.',
      'type': 'new_product',
      'time': '1 ngày trước',
    },
    {
      'id': 'tip_2',
      'title': '💡 Mẹo làm đẹp: Dưỡng da ban đêm',
      'body': 'Ban đêm là thời điểm vàng để dưỡng da. Hãy thử dùng serum Vitamin C kết hợp kem dưỡng ẩm để da sáng mịn vào buổi sáng!',
      'type': 'tip',
      'time': '5 ngày trước',
    },
  ];

  Map<String, String> _statusTitle(String status) {
    switch (status) {
      case 'Đã xác nhận':
        return {
          'title': '✅ Đơn hàng đã được xác nhận!',
          'body': 'Đơn hàng của bạn đã được xác nhận và đang được chuẩn bị. Dự kiến giao hàng trong 2–3 ngày làm việc.',
          'type': 'order_confirmed',
        };
      case 'Đang giao':
        return {
          'title': '🚚 Đơn hàng đang được giao!',
          'body': 'Đơn hàng của bạn đã được bàn giao cho đơn vị vận chuyển và đang trên đường đến bạn.',
          'type': 'order_shipping',
        };
      case 'Hoàn thành':
        return {
          'title': '🎉 Đơn hàng đã giao thành công!',
          'body': 'Đơn hàng của bạn đã được giao thành công. Cảm ơn bạn đã mua sắm tại Beauty & Glow!',
          'type': 'order_done',
        };
      case 'Đã hủy':
        return {
          'title': '❌ Đơn hàng đã bị hủy',
          'body': 'Đơn hàng của bạn đã bị hủy. Nếu bạn đã thanh toán, số tiền sẽ được hoàn lại trong 3–5 ngày làm việc.',
          'type': 'order_cancelled',
        };
      case 'Chờ xử lý':
        return {
          'title': '⏳ Đơn hàng đang chờ xử lý',
          'body': 'Đơn hàng của bạn đã được tiếp nhận và đang chờ xác nhận từ cửa hàng.',
          'type': 'order_pending',
        };
      default:
        return {
          'title': '📦 Cập nhật đơn hàng',
          'body': 'Trạng thái đơn hàng của bạn đã được cập nhật: $status.',
          'type': 'order',
        };
    }
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final dt = ts.toDate();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  void _showDetail(Map<String, dynamic> n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: _getIconBgColor(n['type'] as String), shape: BoxShape.circle),
                  child: Center(child: Icon(_getIconData(n['type'] as String), color: _getIconColor(n['type'] as String), size: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(n['title'] as String, style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.onSurface)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 12),
            Text(n['body'] as String, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: AppColors.onSurface, height: 1.6)),
            if ((n['orderId'] as String? ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Mã đơn: #${(n['orderId'] as String).substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            if ((n['time'] as String? ?? '').isNotEmpty)
              Text(n['time'] as String, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: const Text('Đóng', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Thông báo', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)), centerTitle: false, backgroundColor: AppColors.surface, foregroundColor: AppColors.primary, elevation: 0.5),
        body: const Center(child: Text('Đăng nhập để xem thông báo.', style: TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: () => setState(() => _readIds.addAll(
              _staticNotifs.map((n) => n['id'] as String),
            )),
            child: const Text('Đọc tất cả', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('user_email', isEqualTo: user.email)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Build order notifications from real Firestore data
          final orderNotifs = <Map<String, dynamic>>[];

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final order = doc.data() as Map<String, dynamic>;
              final status = order['status'] as String? ?? '';
              final createdAt = order['updated_at'] as Timestamp? ?? order['created_at'] as Timestamp?;

              // Only show meaningful statuses
              if (['Đã xác nhận', 'Đang giao', 'Hoàn thành', 'Đã hủy', 'Chờ xử lý'].contains(status)) {
                final info = _statusTitle(status);
                orderNotifs.add({
                  'id': doc.id,
                  'orderId': doc.id,
                  'title': info['title']!,
                  'body': info['body']!,
                  'type': info['type']!,
                  'time': _formatTime(createdAt),
                  'is_read': _readIds.contains(doc.id),
                });
              }
            }
          }

          // Combine: order notifs first, then static promos
          final allNotifs = [
            ...orderNotifs,
            ..._staticNotifs.map((n) => {
              ...n,
              'is_read': _readIds.contains(n['id']),
            }),
          ];

          final unreadCount = allNotifs.where((n) => !(n['is_read'] as bool)).length;

          return Column(
            children: [
              // Unread badge bar
              if (unreadCount > 0)
                Container(
                  width: double.infinity,
                  color: AppColors.primaryFixed,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('thông báo chưa đọc', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          for (final n in allNotifs) _readIds.add(n['id'] as String);
                        }),
                        child: const Text('Đọc tất cả', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : allNotifs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🔔', style: TextStyle(fontSize: 64)),
                                SizedBox(height: 16),
                                Text('Không có thông báo nào', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                SizedBox(height: 8),
                                Text('Thông báo đơn hàng sẽ xuất hiện tại đây.', style: TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: allNotifs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final n = allNotifs[index];
                              final isRead = n['is_read'] as bool;
                              final type = n['type'] as String;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => _readIds.add(n['id'] as String));
                                  _showDetail(n);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isRead ? AppColors.surfaceContainerLowest : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isRead ? AppColors.outlineVariant : AppColors.primary.withOpacity(0.2)),
                                    boxShadow: isRead ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(color: _getIconBgColor(type), shape: BoxShape.circle),
                                        child: Center(child: Icon(_getIconData(type), color: _getIconColor(type), size: 22)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    n['title'] as String,
                                                    style: TextStyle(fontFamily: 'DM Sans', fontWeight: isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 13.5, color: AppColors.onSurface),
                                                  ),
                                                ),
                                                if (!isRead) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 8, height: 8,
                                                    margin: const EdgeInsets.only(top: 4),
                                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              n['body'] as String,
                                              style: TextStyle(fontFamily: 'DM Sans', fontSize: 12.5, color: isRead ? AppColors.onSurfaceVariant : AppColors.onSurface.withOpacity(0.8), height: 1.4),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(n['time'] as String, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 10, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'order_confirmed': return Icons.check_circle_outline;
      case 'order_shipping': return Icons.local_shipping_outlined;
      case 'order_done': return Icons.done_all;
      case 'order_cancelled': return Icons.cancel_outlined;
      case 'order_pending': return Icons.hourglass_empty_outlined;
      case 'promo': return Icons.local_offer_outlined;
      case 'new_product': return Icons.new_releases_outlined;
      case 'tip': return Icons.lightbulb_outline;
      default: return Icons.notifications_none;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order_confirmed': return Colors.blue;
      case 'order_shipping': return Colors.orange;
      case 'order_done': return Colors.green;
      case 'order_cancelled': return Colors.red;
      case 'order_pending': return Colors.grey.shade700;
      case 'promo': return AppColors.primary;
      case 'new_product': return Colors.orange;
      case 'tip': return Colors.amber.shade800;
      default: return AppColors.primary;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'order_confirmed': return Colors.blue.withOpacity(0.12);
      case 'order_shipping': return Colors.orange.withOpacity(0.12);
      case 'order_done': return Colors.green.withOpacity(0.12);
      case 'order_cancelled': return Colors.red.withOpacity(0.12);
      case 'order_pending': return Colors.grey.withOpacity(0.12);
      case 'promo': return AppColors.primaryFixed;
      case 'new_product': return Colors.orange.withOpacity(0.12);
      case 'tip': return Colors.amber.withOpacity(0.12);
      default: return AppColors.primaryFixed;
    }
  }
}
