import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.withShadow = true,
    this.rounded = true,
  });

  final double size;
  final bool withShadow;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? size * 0.22 : 0.0;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.07),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: AppColors.coffeeBrown.withValues(alpha: 0.16),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius * 0.78),
        child: Image.asset(
          'assets/icon/app_icon.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
