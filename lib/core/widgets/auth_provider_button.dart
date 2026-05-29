import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

class AuthProviderButton extends StatelessWidget {
  const AuthProviderButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.google = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool google;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        side: BorderSide(color: AppColors.greyText.withValues(alpha: 0.24)),
        backgroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (google)
            const _GoogleMark()
          else
            Icon(icon, color: AppColors.primaryBrown),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(
        AppAssets.googleLogoPath,
        errorBuilder: (_, __, ___) => CustomPaint(
          painter: _GoogleMarkPainter(),
        ),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect = Offset(stroke, stroke) &
        Size(size.width - stroke * 2, size.height - stroke * 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.08 * math.pi, 0.55 * math.pi, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.47 * math.pi, 0.48 * math.pi, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 0.95 * math.pi, 0.42 * math.pi, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 1.37 * math.pi, 0.50 * math.pi, false, paint);

    final centerY = size.height * 0.5;
    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * 0.52, centerY),
      Offset(size.width * 0.86, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.86, centerY),
      Offset(size.width * 0.86, size.height * 0.38),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
