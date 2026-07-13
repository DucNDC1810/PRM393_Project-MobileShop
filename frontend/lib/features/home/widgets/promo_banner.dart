import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Dưỡng da\nCăng bóng',
      'subtitle': 'Ưu đãi đến 30% cho dòng sản phẩm Skincare',
      'cta': 'Mua ngay',
      'emoji': '🧴',
      'gradient': [const Color(0xFFE89A9B), const Color(0xFFF7C5C6)],
    },
    {
      'title': 'Sắc màu\nThời thượng',
      'subtitle': 'Son Velvet Matte & Nhũ lấp lánh giảm 20%',
      'cta': 'Xem ưu đãi',
      'emoji': '💄',
      'gradient': [const Color(0xFFC84B5B), const Color(0xFFE58C96)],
    },
    {
      'title': 'Nước hoa\nHương gỗ ấm',
      'subtitle': 'Khám phá bộ sưu tập mùi hương sang trọng',
      'cta': 'Khám phá',
      'emoji': '🧪',
      'gradient': [const Color(0xFF8A5C7F), const Color(0xFFB593AD)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190, // Increased height to prevent overflow
          child: PageView.builder(
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: b['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (b['gradient'] as List<Color>).first.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16), // Balanced padding
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b['title'] as String,
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                b['cta'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: (b['gradient'] as List<Color>).first,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        b['emoji'] as String,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary
                    : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4), // Spacing below indicator dots to avoid overlapping category chips
      ],
    );
  }
}
