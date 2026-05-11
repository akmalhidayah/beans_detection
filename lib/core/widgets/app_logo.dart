import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 92});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrown.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CoffeeBeanLogoPainter(),
      ),
    );
  }
}

class _CoffeeBeanLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final beanPaint = Paint()
      ..color = AppColors.primaryBrown
      ..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..color = AppColors.secondaryBrown
      ..strokeWidth = size.width * 0.055
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy + size.height * 0.04);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.46,
        height: size.height * 0.66,
      ),
      beanPaint,
    );
    final seam = Path()
      ..moveTo(0, -size.height * 0.22)
      ..cubicTo(
        -size.width * 0.08,
        -size.height * 0.05,
        size.width * 0.10,
        size.height * 0.06,
        0,
        size.height * 0.24,
      );
    canvas.drawPath(seam, highlightPaint);
    canvas.restore();

    final leaf = Path()
      ..moveTo(center.dx + size.width * 0.08, center.dy - size.height * 0.30)
      ..quadraticBezierTo(
        center.dx + size.width * 0.36,
        center.dy - size.height * 0.38,
        center.dx + size.width * 0.35,
        center.dy - size.height * 0.08,
      )
      ..quadraticBezierTo(
        center.dx + size.width * 0.15,
        center.dy - size.height * 0.11,
        center.dx + size.width * 0.08,
        center.dy - size.height * 0.30,
      );
    canvas.drawPath(leaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
