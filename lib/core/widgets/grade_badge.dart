import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradeBadge extends StatelessWidget {
  const GradeBadge({
    super.key,
    required this.grade,
    this.compact = false,
  });

  final String grade;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(grade);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        grade,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }

  static Color gradeColor(String grade) {
    if (grade.contains('A')) return AppColors.green;
    if (grade.contains('B')) return AppColors.orangeGold;
    return AppColors.redAccent;
  }
}
