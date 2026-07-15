import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static Stream<QuerySnapshot> streamFor(String uid) =>
      FirebaseFirestore.instance
          .collection('notifications')
          .where('user_uid', isEqualTo: uid)
          .snapshots();

  static Future<int> unreadCount(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('user_uid', isEqualTo: uid)
        .where('is_read', isEqualTo: false)
        .get();
    return snap.docs.length;
  }

  Future<void> _markAllRead(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('user_uid', isEqualTo: uid)
        .where('is_read', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_read': true});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thông báo')),
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    _markAllRead(user.uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo',
            style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: streamFor(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snapshot.data?.docs ?? [];
          // Sort by created_at descending in memory
          docs.sort((a, b) {
            final aT = (a.data() as Map)['created_at'] as Timestamp?;
            final bT = (b.data() as Map)['created_at'] as Timestamp?;
            if (aT == null || bT == null) return 0;
            return bT.compareTo(aT);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 72, color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('Chưa có thông báo nào',
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 16,
                          fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  const Text('Các cập nhật về đơn hàng sẽ hiển thị ở đây',
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 13,
                          color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.outlineVariant, indent: 72),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isRead = data['is_read'] as bool? ?? true;
              final title = data['title'] as String? ?? '';
              final body = data['body'] as String? ?? '';
              final type = data['type'] as String? ?? 'order';
              final createdAt = (data['created_at'] as Timestamp?)?.toDate();

              return _NotificationTile(
                title: title,
                body: body,
                type: type,
                isRead: isRead,
                createdAt: createdAt,
                onTap: () async {
                  await docs[index].reference.update({'is_read': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case 'order': return Icons.shopping_bag_outlined;
      case 'wallet': return Icons.account_balance_wallet_outlined;
      case 'promo': return Icons.local_offer_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'order': return AppColors.primary;
      case 'wallet': return Colors.orange;
      case 'promo': return Colors.green;
      default: return Colors.blue;
    }
  }

  String get _timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.onSurface,
                            )),
                      ),
                      if (!isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          fontFamily: 'DM Sans', fontSize: 13,
                          color: AppColors.onSurfaceVariant, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(_timeAgo,
                      style: const TextStyle(
                          fontFamily: 'DM Sans', fontSize: 11,
                          color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
