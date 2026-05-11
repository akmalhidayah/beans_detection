import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_placeholder.dart';
import '../../../models/detection_result.dart';

class BoundingBoxPreview extends StatelessWidget {
  const BoundingBoxPreview({super.key, required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          const CoffeePlaceholder(
            height: 240,
            title: 'Gambar hasil deteksi',
            subtitle: 'Visualisasi bounding box dummy',
          ),
          Positioned(
            left: 58,
            top: 58,
            right: 42,
            bottom: 46,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 58,
            top: 34,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${result.coffeeType} - ${result.grade} ${result.confidenceText}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
