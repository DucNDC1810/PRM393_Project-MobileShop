import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

/// Shared widget that displays a product image from URL, or an emoji fallback.
class ProductImage extends StatelessWidget {
  final Map<String, dynamic> product;
  final String emoji;
  final double emojiSize;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.product,
    required this.emoji,
    this.emojiSize = 40,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  String? _resolveUrl() {
    final images = product['images'];
    if (images is List && images.isNotEmpty) {
      final url = images.first?.toString() ?? '';
      if (url.startsWith('http')) return url;
    }
    final fallback = product['image_url']?.toString() ?? '';
    if (fallback.startsWith('http')) return fallback;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl();
    final fallback = Center(
      child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
    );

    if (url == null) return fallback;

    Widget img = Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        );
      },
      errorBuilder: (_, __, ___) => fallback,
    );

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }

    return img;
  }
}
