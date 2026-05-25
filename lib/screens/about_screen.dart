import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/info_card.dart';
import '../core/widgets/section_title.dart';

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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: AppLogo(size: 104)),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.darkText,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Judul Skripsi'),
                  const SizedBox(height: 12),
                  const InfoCard(
                    child: Text(
                      'Klasifikasi Kualitas Biji Kopi Berdasarkan Citra Digital Dengan Menggunakan Metode YOLOv11',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Deskripsi Aplikasi'),
                  const SizedBox(height: 12),
                  const InfoCard(
                    child: Text(
                      'Aplikasi ini dirancang untuk membantu pengguna mengklasifikasikan kualitas biji kopi Arabika dan Robusta berdasarkan citra digital. Proses training dataset dan pengelolaan model dilakukan di backend atau proses terpisah, sedangkan aplikasi Android berfokus pada pengalaman user.',
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Fitur Utama'),
                  const SizedBox(height: 12),
                  const _BulletCard(
                    items: [
                      'Scan kamera',
                      'Upload gambar',
                      'Klasifikasi kualitas Grade A/B/C',
                      'Confidence score',
                      'Riwayat deteksi',
                      'Informasi karakteristik fisik biji kopi',
                    ],
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Karakteristik Fisik'),
                  const SizedBox(height: 12),
                  const _BulletCard(
                    items: [
                      'Bentuk dan keutuhan biji',
                      'Ukuran biji',
                      'Permukaan biji',
                      'Warna biji',
                    ],
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Teknologi'),
                  const SizedBox(height: 12),
                  const InfoCard(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _TechChip(label: 'Flutter'),
                        _TechChip(label: 'Dart'),
                        _TechChip(label: 'YOLOv11'),
                        _TechChip(label: 'Python'),
                        _TechChip(label: 'OpenCV'),
                        _TechChip(label: 'Confusion Matrix'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Status'),
                  const SizedBox(height: 12),
                  const InfoCard(
                    child: Text(
                      'Aplikasi terhubung ke backend FastAPI dan model YOLOv11 melalui endpoint prediksi.',
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

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
