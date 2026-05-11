import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/info_card.dart';
import '../../../models/detection_result.dart';

class ResultHeaderCard extends StatelessWidget {
  const ResultHeaderCard({super.key, required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        children: [
          _ResultRow(label: 'Jenis Kopi', value: result.coffeeType),
          _ResultRow(label: 'Kualitas', value: result.grade),
          _ResultRow(label: 'Confidence', value: result.confidenceText),
          _ResultRow(label: 'Status', value: result.status, isLast: true),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyText,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
