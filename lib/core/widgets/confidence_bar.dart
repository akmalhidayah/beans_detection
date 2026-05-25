import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({
    super.key,
    required this.value,
    this.color,
  });

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0, 100) / 100;
    final barColor = color ?? AppColors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Confidence score',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.cream,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
