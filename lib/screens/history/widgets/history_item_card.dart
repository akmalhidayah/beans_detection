import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/detection_result.dart';

class HistoryItemCard extends StatelessWidget {
  const HistoryItemCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  final DetectionResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(result.grade);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: AppColors.primaryBrown,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.coffeeType,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: gradeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.grade,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: gradeColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.confidenceText} - ${result.status}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.format(result.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    if (grade.contains('A')) return AppColors.green;
    if (grade.contains('B')) return AppColors.orangeGold;
    return AppColors.redAccent;
  }
}
