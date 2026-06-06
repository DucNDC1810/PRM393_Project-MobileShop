import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  int _currentPage = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Siêu phẩm\nGalaxy S24',
      'subtitle': 'Trả góp 0% • Trải nghiệm quyền năng AI',
      'cta': 'Khám phá',
      'emoji': '📱',
      'gradient': [const Color(0xFF805531), const Color(0xFFC9956C)],
    },
    {
      'title': 'Tai nghe\nKhông dây Pro',
      'subtitle': 'Âm thanh đỉnh cao • Giảm ngay 20%',
      'cta': 'Mua ngay',
      'emoji': '🎧',
      'gradient': [const Color(0xFF665C61), const Color(0xFFEADCE2)],
    },
    {
      'title': 'Phụ kiện\nChính hãng',
      'subtitle': 'Cáp sạc, ốp lưng • Giảm đến 50%',
      'cta': 'Xem ưu đãi',
      'emoji': '🔌',
      'gradient': [const Color(0xFFC9956C), const Color(0xFFF4BB8F)],
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
          // Dot indicators
        ),
      ],
    );
  }
}
