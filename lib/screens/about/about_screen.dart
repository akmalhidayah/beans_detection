import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_title.dart';
import 'widgets/about_feature_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Center(child: AppLogo(size: 104)),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 14),
                  const InfoCard(
                    child: Text(
                      'Aplikasi ini dirancang untuk membantu petani dan UMKM dalam mengidentifikasi kualitas biji kopi Arabika dan Robusta menggunakan teknologi computer vision.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SectionTitle(title: 'Fitur Utama'),
                  ),
                  const SizedBox(height: 12),
                  const AboutFeatureCard(
                    title: 'Deteksi jenis kopi',
                    icon: Icons.coffee_rounded,
                  ),
                  const SizedBox(height: 10),
                  const AboutFeatureCard(
                    title: 'Klasifikasi Grade A/B/C',
                    icon: Icons.workspace_premium_rounded,
                  ),
                  const SizedBox(height: 10),
                  const AboutFeatureCard(
                    title: 'Analisis karakteristik fisik',
                    icon: Icons.fact_check_rounded,
                  ),
                  const SizedBox(height: 10),
                  const AboutFeatureCard(
                    title: 'Riwayat deteksi',
                    icon: Icons.history_rounded,
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: SectionTitle(title: 'Teknologi'),
                  ),
                  const SizedBox(height: 12),
                  const InfoCard(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _TechChip(label: 'Flutter'),
                        _TechChip(label: 'YOLOv11'),
                        _TechChip(label: 'Backend API'),
                        _TechChip(label: 'Computer Vision'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const InfoCard(
                    child: Text(
                      'Catatan: Versi UI awal menggunakan dummy data dan belum terhubung ke backend.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
