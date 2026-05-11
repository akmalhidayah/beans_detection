import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CoffeePlaceholder extends StatelessWidget {
  const CoffeePlaceholder({
    super.key,
    this.height = 220,
    this.iconSize = 58,
    this.title = 'Preview gambar biji kopi',
    this.subtitle = 'Pastikan biji kopi terlihat jelas dan pencahayaan cukup.',
  });

  final double height;
  final double iconSize;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.secondaryBrown.withValues(alpha: 0.18)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CoffeePatternPainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_camera_rounded,
                  size: iconSize,
                  color: AppColors.primaryBrown,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyText,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoffeePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondaryBrown.withValues(alpha: 0.09);
    final positions = [
      Offset(size.width * 0.18, size.height * 0.25),
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.25, size.height * 0.78),
      Offset(size.width * 0.82, size.height * 0.72),
    ];
    for (final position in positions) {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(0.55);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 28, height: 44),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
