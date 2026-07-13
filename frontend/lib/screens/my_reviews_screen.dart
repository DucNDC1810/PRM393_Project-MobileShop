import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Đánh giá của tôi',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: user == null
          ? const Center(
              child: Text('Vui lòng đăng nhập để xem đánh giá.',
                  style: TextStyle(fontFamily: 'DM Sans')),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('user_email', isEqualTo: user.email)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}',
                        style: const TextStyle(fontFamily: 'DM Sans')),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⭐', style: TextStyle(fontSize: 64)),
                        SizedBox(height: 16),
                        Text(
                          'Bạn chưa có đánh giá nào',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mua hàng và đánh giá sản phẩm\nđể chia sẻ trải nghiệm của bạn!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
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
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _MyReviewCard(data: data);
                  },
                );
              },
            ),
    );
  }
}

class _MyReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _MyReviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final productName = data['product_name'] as String? ?? 'Sản phẩm';
    final productEmoji = data['product_emoji'] as String? ?? '✨';
    final stars = data['stars'] as int? ?? 5;
    final comment = data['comment'] as String? ?? '';
    final createdAt = (data['created_at'] as Timestamp?)?.toDate();
    final dateStr = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name + emoji
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(productEmoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Star row
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFBC02D),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _starLabel(stars),
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Date
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),

          // Comment
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    comment,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _starLabel(int s) {
    switch (s) {
      case 1: return 'Rất tệ';
      case 2: return 'Tệ';
      case 3: return 'Bình thường';
      case 4: return 'Tốt';
      case 5: return 'Xuất sắc';
      default: return '';
    }
  }
}
