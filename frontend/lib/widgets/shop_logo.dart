import 'package:flutter/material.dart';

class ShopLogo extends StatelessWidget {
  final double size;

  const ShopLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShopLogoPainter(),
      ),
    );
  }
}

class _ShopLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final scaleX = s / 80;
    final scaleY = s / 80;

    // White circle background
    final circlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, circlePaint);

    // Petal / flower shape - pink (#E8547A)
    final petalPaint = Paint()
      ..color = const Color(0xFFE8547A)
      ..style = PaintingStyle.fill;

    final petalPath = Path();
    // Translated path from SVG: M40 25C42 20 48 20 50 25C55 27 55 33 50 35C52 40 48 45 42 45C40 50 34 50 32 45C26 43 26 37 31 35C29 30 33 25 39 25
    petalPath.moveTo(40 * scaleX, 25 * scaleY);
    petalPath.cubicTo(42 * scaleX, 20 * scaleY, 48 * scaleX, 20 * scaleY, 50 * scaleX, 25 * scaleY);
    petalPath.cubicTo(55 * scaleX, 27 * scaleY, 55 * scaleX, 33 * scaleY, 50 * scaleX, 35 * scaleY);
    petalPath.cubicTo(52 * scaleX, 40 * scaleY, 48 * scaleX, 45 * scaleY, 42 * scaleX, 45 * scaleY);
    petalPath.cubicTo(40 * scaleX, 50 * scaleY, 34 * scaleX, 50 * scaleY, 32 * scaleX, 45 * scaleY);
    petalPath.cubicTo(26 * scaleX, 43 * scaleY, 26 * scaleX, 37 * scaleY, 31 * scaleX, 35 * scaleY);
    petalPath.cubicTo(29 * scaleX, 30 * scaleY, 33 * scaleX, 25 * scaleY, 39 * scaleX, 25 * scaleY);
    petalPath.close();
    canvas.drawPath(petalPath, petalPaint);

    // Inner highlight - light pink (#FDE8EF)
    final highlightPaint = Paint()
      ..color = const Color(0xFFFDE8EF)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    // M40 33C40 33 42 30 45 32C48 34 45 38 40 37C35 38 32 34 35 32C38 30 40 33 40 33Z
    highlightPath.moveTo(40 * scaleX, 33 * scaleY);
    highlightPath.cubicTo(40 * scaleX, 33 * scaleY, 42 * scaleX, 30 * scaleY, 45 * scaleX, 32 * scaleY);
    highlightPath.cubicTo(48 * scaleX, 34 * scaleY, 45 * scaleX, 38 * scaleY, 40 * scaleX, 37 * scaleY);
    highlightPath.cubicTo(35 * scaleX, 38 * scaleY, 32 * scaleX, 34 * scaleY, 35 * scaleX, 32 * scaleY);
    highlightPath.cubicTo(38 * scaleX, 30 * scaleY, 40 * scaleX, 33 * scaleY, 40 * scaleX, 33 * scaleY);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
