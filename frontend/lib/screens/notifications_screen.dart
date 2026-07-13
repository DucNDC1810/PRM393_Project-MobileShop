import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': '🎉 Đơn hàng đã được xác nhận!',
      'body': 'Đơn hàng #A3F21B của bạn đã được xác nhận và đang được đóng gói. Dự kiến giao hàng trong 2–3 ngày làm việc.',
      'time': '10 phút trước',
      'type': 'order',
      'is_read': false,
    },
    {
      'title': '🚚 Đơn hàng đang được giao',
      'body': 'Đơn hàng #B7C90D đã được giao cho đơn vị vận chuyển. Bạn có thể theo dõi đơn hàng trong mục "Đơn hàng của tôi".',
      'time': '1 giờ trước',
      'type': 'order',
      'is_read': false,
    },
    {
      'title': '⚡ Flash Sale Mỹ Phẩm – Giảm đến 40%!',
      'body': 'Hôm nay duy nhất! Toàn bộ sản phẩm Innisfree, Laneige và The Face Shop giảm giá sốc đến 40%. Nhập mã BEAUTY40 để áp dụng ngay!',
      'time': '3 giờ trước',
      'type': 'promo',
      'is_read': false,
    },
    {
      'title': '🌸 Sản phẩm mới vừa về!',
      'body': 'Bộ dưỡng da Laneige Water Bank Blue Hyaluronic vừa có mặt tại Beauty & Glow. Sản phẩm giữ ẩm chuyên sâu cho mọi loại da.',
      'time': '1 ngày trước',
      'type': 'new_product',
      'is_read': false,
    },
    {
      'title': '💌 Ưu đãi thành viên tháng 7',
      'body': 'Là thành viên Gold, bạn được tặng thêm 15% cho mọi đơn hàng trong tháng 7. Ưu đãi áp dụng tự động khi thanh toán.',
      'time': '2 ngày trước',
      'type': 'promo',
      'is_read': true,
    },
    {
      'title': '✅ Đơn hàng hoàn tất',
      'body': 'Đơn hàng #C4D11E đã được giao thành công. Hãy đánh giá sản phẩm để nhận thêm điểm thưởng nhé!',
      'time': '3 ngày trước',
      'type': 'order',
      'is_read': true,
    },
    {
      'title': '💡 Mẹo làm đẹp: Dưỡng da ban đêm',
      'body': 'Ban đêm là thời điểm vàng để dưỡng da. Hãy thử dùng serum Vitamin C kết hợp kem dưỡng ẩm để da sáng mịn vào buổi sáng!',
      'time': '5 ngày trước',
      'type': 'tip',
      'is_read': true,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !(n['is_read'] as bool)).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n['is_read'] = true;
      }
    });
  }

  void _markRead(int index) {
    if (!(_notifications[index]['is_read'] as bool)) {
      setState(() => _notifications[index]['is_read'] = true);
    }
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
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
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
                  child: Text(
                    n['title'] as String,
                    style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text(
              n['body'] as String,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: AppColors.onSurface, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              n['time'] as String,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Thông báo', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: Text('$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Đọc tất cả', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔔', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('Không có thông báo nào', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  SizedBox(height: 8),
                  Text('Thông báo mới sẽ xuất hiện tại đây.', style: TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = _notifications[index];
                final isRead = n['is_read'] as bool;

                return GestureDetector(
                  onTap: () {
                    _markRead(index);
                    _showDetail(n);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? AppColors.surfaceContainerLowest : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isRead ? AppColors.outlineVariant : AppColors.primary.withOpacity(0.2)),
                      boxShadow: isRead
                          ? []
                          : [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: _getIconBgColor(n['type'] as String), shape: BoxShape.circle),
                          child: Center(child: Icon(_getIconData(n['type'] as String), color: _getIconColor(n['type'] as String), size: 22)),
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
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                        fontSize: 13.5,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!isRead)
                                    Container(
                                      width: 8, height: 8,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                n['body'] as String,
                                style: TextStyle(fontFamily: 'DM Sans', fontSize: 12.5, color: isRead ? AppColors.onSurfaceVariant : AppColors.onSurface.withOpacity(0.75), height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
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
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'order': return Icons.local_shipping_outlined;
      case 'promo': return Icons.local_offer_outlined;
      case 'new_product': return Icons.new_releases_outlined;
      case 'tip': return Icons.lightbulb_outline;
      default: return Icons.notifications_none;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order': return Colors.green;
      case 'promo': return AppColors.primary;
      case 'new_product': return Colors.orange;
      case 'tip': return Colors.amber.shade800;
      default: return AppColors.primary;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'order': return Colors.green.withOpacity(0.12);
      case 'promo': return AppColors.primaryFixed;
      case 'new_product': return Colors.orange.withOpacity(0.12);
      case 'tip': return Colors.amber.withOpacity(0.12);
      default: return AppColors.primaryFixed;
    }
  }
}
