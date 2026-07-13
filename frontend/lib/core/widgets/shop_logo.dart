import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

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

    // Background circle (clean white/light peach tint)
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, circlePaint);

    // Dynamic brand colors
    final primaryColor = color ?? AppColors.primary;
    final secondaryColor = AppColors.primaryContainer;

    // 1. Draw Cap (Gold/Rose gold cap on top)
    final capPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(32 * scaleX, 12 * scaleY, 16 * scaleX, 10 * scaleY),
      Radius.circular(3 * scaleX),
    );
    canvas.drawRRect(capRect, capPaint);

    // 2. Draw Neck / Collar
    final neckPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    final neckRect = Rect.fromLTWH(36 * scaleX, 22 * scaleY, 8 * scaleX, 4 * scaleY);
    canvas.drawRect(neckRect, neckPaint);

    // 3. Draw Glass Bottle Outline
    final bottleOutlinePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scaleX
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final bottleBodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20 * scaleX, 26 * scaleY, 40 * scaleX, 44 * scaleY),
      Radius.circular(8 * scaleX),
    );
    canvas.drawRRect(bottleBodyRect, bottleOutlinePaint);

    // 4. Fill Bottle with soft liquid color (semi-transparent pink)
    final liquidPaint = Paint()
      ..color = primaryColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final liquidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(23 * scaleX, 29 * scaleY, 34 * scaleX, 38 * scaleY),
      Radius.circular(5 * scaleX),
    );
    canvas.drawRRect(liquidRect, liquidPaint);

    // 5. Draw Luxury Gold/Rose Heart Label inside the bottle
    final labelPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final heartPath = Path();
    heartPath.moveTo(40 * scaleX, 43 * scaleY);
    // Left lobe
    heartPath.cubicTo(
      36 * scaleX, 39 * scaleY, 
      31 * scaleX, 41 * scaleY, 
      32 * scaleX, 46 * scaleY,
    );
    // Down to bottom tip
    heartPath.cubicTo(
      32 * scaleX, 51 * scaleY, 
      40 * scaleX, 56 * scaleY, 
      40 * scaleX, 58 * scaleY,
    );
    // Up from bottom tip to right lobe
    heartPath.cubicTo(
      40 * scaleX, 56 * scaleY, 
      48 * scaleX, 51 * scaleY, 
      48 * scaleX, 46 * scaleY,
    );
    // Right lobe back to center
    heartPath.cubicTo(
      49 * scaleX, 41 * scaleY, 
      44 * scaleX, 39 * scaleY, 
      40 * scaleX, 43 * scaleY,
    );
    canvas.drawPath(heartPath, labelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
