import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Hiển thị bottom sheet để khách hàng đánh giá các sản phẩm trong đơn đã hoàn thành.
void showReviewSheet(BuildContext context, String orderId, List items) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReviewSheet(orderId: orderId, items: items),
  );
}

class _ReviewSheet extends StatefulWidget {
  final String orderId;
  final List items;

  const _ReviewSheet({required this.orderId, required this.items});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  // Mỗi sản phẩm: star rating + comment controller
  late List<int> _stars;
  late List<TextEditingController> _controllers;
  bool _isSubmitting = false;
  // Track which products already reviewed in this order
  Set<String> _alreadyReviewed = {};

  @override
  void initState() {
    super.initState();
    _stars = List.filled(widget.items.length, 5);
    _controllers = List.generate(widget.items.length, (_) => TextEditingController());
    _checkAlreadyReviewed();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAlreadyReviewed() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('reviews')
        .where('order_id', isEqualTo: widget.orderId)
        .where('user_email', isEqualTo: user.email)
        .get();
    if (!mounted) return;
    setState(() {
      _alreadyReviewed = snap.docs.map((d) => d['product_id'] as String).toSet();
    });
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    final batch = FirebaseFirestore.instance.batch();
    final reviewsRef = FirebaseFirestore.instance.collection('reviews');

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i] as Map<String, dynamic>;
      final productId = item['id'] as String? ?? '';
      if (productId.isEmpty || _alreadyReviewed.contains(productId)) continue;

      final comment = _controllers[i].text.trim();

      // Extract image url from item
      String? productImage;
      final imagesList = item['images'];
      if (imagesList is List && imagesList.isNotEmpty) {
        final first = imagesList.first?.toString() ?? '';
        if (first.startsWith('http')) productImage = first;
      } else if (item['image_url'] != null) {
        final url = item['image_url'].toString();
        if (url.startsWith('http')) productImage = url;
      }

      final docRef = reviewsRef.doc();
      batch.set(docRef, {
        'product_id': productId,
        'product_name': item['name'] ?? '',
        'product_emoji': item['emoji'] ?? '✨',
        'product_image': productImage ?? '',
        'order_id': widget.orderId,
        'user_email': user.email,
        'user_name': user.displayName ?? 'Khách hàng',
        'stars': _stars[i],
        'comment': comment,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã đánh giá! 🌟',
                style: TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi đánh giá: $e',
                style: const TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreviewed = widget.items.where((item) {
      final id = (item as Map<String, dynamic>)['id'] as String? ?? '';
      return !_alreadyReviewed.contains(id);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFBC02D), size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Đánh giá sản phẩm',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            if (unreviewed.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✅', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text(
                        'Bạn đã đánh giá tất cả sản phẩm\ntrong đơn hàng này.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const Text(
                      'Hãy chia sẻ trải nghiệm của bạn về các sản phẩm!',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value as Map<String, dynamic>;
                      final productId = item['id'] as String? ?? '';
                      final alreadyDone = _alreadyReviewed.contains(productId);
                      return _ProductReviewCard(
                        item: item,
                        stars: _stars[i],
                        controller: _controllers[i],
                        alreadyReviewed: alreadyDone,
                        onStarChanged: (s) => setState(() => _stars[i] = s),
                      );
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'Gửi đánh giá',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductReviewCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int stars;
  final TextEditingController controller;
  final bool alreadyReviewed;
  final ValueChanged<int> onStarChanged;

  const _ProductReviewCard({
    required this.item,
    required this.stars,
    required this.controller,
    required this.alreadyReviewed,
    required this.onStarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? 'Sản phẩm';
    final brand = item['brand'] as String? ?? '';
    final emoji = item['emoji'] as String? ?? '✨';

    final imagesList = item['images'];
    String? imageUrl;
    if (imagesList is List && imagesList.isNotEmpty) {
      imageUrl = imagesList.first?.toString();
    } else if (item['image_url'] != null) {
      imageUrl = item['image_url'].toString();
    }
    final hasImage = imageUrl != null && imageUrl.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alreadyReviewed
            ? AppColors.surfaceContainerLow
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alreadyReviewed
              ? Colors.green.shade200
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(imageUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Center(child: Text(emoji, style: const TextStyle(fontSize: 24)))),
                      )
                    : Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
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
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (brand.isNotEmpty)
                      Text(
                        brand,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (alreadyReviewed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Text(
                    '✅ Đã đánh giá',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),

          if (!alreadyReviewed) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: 14),

            // Star rating
            const Text(
              'Xếp hạng:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (starIdx) {
                final filled = starIdx < stars;
                return GestureDetector(
                  onTap: () => onStarChanged(starIdx + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: const Color(0xFFFBC02D),
                      size: 34,
                    ),
                  ),
                );
              }),
              // Label next to stars
            ),
            const SizedBox(height: 4),
            Text(
              _starLabel(stars),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Comment text field
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 300,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm này...',
                hintStyle: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
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
      case 5: return 'Xuất sắc! ⭐';
      default: return '';
    }
  }
}
