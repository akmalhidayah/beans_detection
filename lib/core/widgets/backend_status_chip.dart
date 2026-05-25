import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_language.dart';

class BackendStatusChip extends StatelessWidget {
  const BackendStatusChip({
    super.key,
    required this.isOnline,
    required this.language,
    this.onRefresh,
  });

  final bool isOnline;
  final String language;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.green : AppColors.greyText;
    final label = isOnline
        ? AppLanguage.text('online', language)
        : AppLanguage.text('offline', language);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Backend $label',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (onRefresh != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.refresh_rounded, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
