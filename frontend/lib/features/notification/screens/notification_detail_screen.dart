import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final String body;
  final String type;
  final DateTime? createdAt;
  final Map<String, dynamic> extra;

  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.body,
    required this.type,
    this.createdAt,
    this.extra = const {},
  });

  IconData get _icon {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'order':
        return AppColors.primary;
      case 'wallet':
        return Colors.orange;
      case 'promo':
        return Colors.green;
      case 'chat':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String get _typeLabel {
    switch (type) {
      case 'order':
        return 'Đơn hàng';
      case 'wallet':
        return 'Ví tiền';
      case 'promo':
        return 'Khuyến mãi';
      case 'chat':
        return 'Tin nhắn';
      default:
        return 'Thông báo';
    }
  }

  String get _formattedDate {
    if (createdAt == null) return '';
    final d = createdAt!;
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$hour:$min  ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Chi tiết thông báo',
          style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + type badge
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, color: _iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _typeLabel,
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _iconColor),
                      ),
                    ),
                    if (_formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formattedDate,
                        style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1.3),
            ),
            const SizedBox(height: 12),

            // Divider
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 12),

            // Body content
            Text(
              body,
              style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  color: AppColors.onSurface,
                  height: 1.6),
            ),

            // Extra info (e.g. order_id)
            if (extra.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: extra.entries.map((e) {
                    final label = _extraLabel(e.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            '$label: ',
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant),
                          ),
                          Text(
                            '${e.value}',
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _extraLabel(String key) {
    switch (key) {
      case 'order_id':
        return 'Mã đơn hàng';
      case 'amount':
        return 'Số tiền';
      default:
        return key;
    }
  }
}
