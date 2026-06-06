import 'package:flutter/material.dart';

class ShopLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const ShopLogo({super.key, this.size = 36, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShopLogoPainter(color: color),
      ),
    );
  }
}

class _ShopLogoPainter extends CustomPainter {
  final Color? color;

  _ShopLogoPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final scaleX = s / 80;
    final scaleY = s / 80;

    // Background circle (clean white/light blue tint)
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, circlePaint);

    // Tech blue/indigo color for the main body
    final primaryColor = color ?? const Color(0xFF0F62FE);
    final secondaryColor = const Color(0xFF3B82F6);

    // Draw Phone Body
    final phonePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Draw phone body (rounded rectangle)
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(26 * scaleX, 16 * scaleY, 28 * scaleX, 48 * scaleY),
      Radius.circular(6 * scaleX),
    );
    canvas.drawRRect(phoneRect, phonePaint);

    // Draw Phone Screen (inner rectangle)
    final screenPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(29 * scaleX, 22 * scaleY, 22 * scaleX, 36 * scaleY),
      Radius.circular(3 * scaleX),
    );
    canvas.drawRRect(screenRect, screenPaint);

    // Draw Notch
    final notchPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final notchRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(36 * scaleX, 16 * scaleY, 8 * scaleX, 3 * scaleY),
      bottomLeft: Radius.circular(2 * scaleX),
      bottomRight: Radius.circular(2 * scaleX),
    );
    canvas.drawRRect(notchRect, notchPaint);

    // Draw a shopping cart / lightning bolt inside the screen to represent commerce/speed
    final accentPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final cartPath = Path();
    // A simplified sleek shopping cart icon
    cartPath.moveTo(33 * scaleX, 27 * scaleY);
    cartPath.lineTo(36 * scaleX, 27 * scaleY);
    cartPath.lineTo(38 * scaleX, 38 * scaleY);
    cartPath.lineTo(47 * scaleX, 38 * scaleY);
    cartPath.lineTo(49 * scaleX, 30 * scaleY);
    cartPath.lineTo(37 * scaleX, 30 * scaleY);
    canvas.drawPath(cartPath, Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scaleX
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Wheels of the cart
    canvas.drawCircle(Offset(39 * scaleX, 42 * scaleY), 2.5 * scaleX, accentPaint);
    canvas.drawCircle(Offset(46 * scaleX, 42 * scaleY), 2.5 * scaleX, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
