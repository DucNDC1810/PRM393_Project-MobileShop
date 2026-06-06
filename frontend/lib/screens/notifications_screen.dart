import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': '🎉 Đơn hàng đã tiếp nhận!',
        'body': 'Đơn hàng của bạn đã được tiếp nhận thành công và đang chuyển cho bộ phận đóng gói. Cảm ơn bạn!',
        'time': '10 phút trước',
        'type': 'order',
        'is_read': false,
      },
      {
        'title': '⚡ Siêu Khuyến Mãi Flash Sale',
        'body': 'Cơ hội vàng! Nhập mã GIAM10 để được giảm giá 10% cho tất cả các sản phẩm điện thoại và phụ kiện chính hãng hôm nay.',
        'time': '2 giờ trước',
        'type': 'promo',
        'is_read': false,
      },
      {
        'title': '🔋 Cập nhật cửa hàng Cầu Giấy',
        'body': 'Chi nhánh Cầu Giấy vừa về thêm số lượng lớn iPhone 15 Pro Max và iPad Air M2 sẵn sàng giao ngay cho quý khách.',
        'time': '1 ngày trước',
        'type': 'info',
        'is_read': true,
      },
      {
        'title': '🔒 Bảo mật tài khoản thành công',
        'body': 'Bạn đã cập nhật mật khẩu tài khoản thành công. Vui lòng không chia sẻ mã OTP cho bất kỳ ai.',
        'time': '3 ngày trước',
        'type': 'security',
        'is_read': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = notifications[index];
          final isRead = n['is_read'] as bool;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRead ? AppColors.outlineVariant : AppColors.primary.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBgColor(n['type'] as String),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getIconData(n['type'] as String),
                      color: _getIconColor(n['type'] as String),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n['body'] as String,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.5,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        n['time'] as String,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'info':
        return Icons.info_outline;
      case 'security':
        return Icons.lock_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order':
        return Colors.green;
      case 'promo':
        return AppColors.primary;
      case 'info':
        return Colors.blue;
      case 'security':
        return Colors.amber.shade800;
      default:
        return AppColors.primary;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'order':
        return Colors.green.withOpacity(0.12);
      case 'promo':
        return AppColors.primaryFixed;
      case 'info':
        return Colors.blue.withOpacity(0.12);
      case 'security':
        return Colors.amber.withOpacity(0.12);
      default:
        return AppColors.primaryFixed;
    }
  }
}
