import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            Material(
              color: AppColors.cream,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onProfileTap,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryBrown,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Halo!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w900,
              ),
        ),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Analisis kualitas Arabika & Robusta berbasis AI.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.greyText,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _InfoChip(label: 'Arabika'),
            _InfoChip(label: 'Robusta'),
            _InfoChip(label: 'Grade A/B/C'),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
