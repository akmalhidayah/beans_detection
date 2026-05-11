import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_title.dart';
import '../detection/detection_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.cream,
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryBrown,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Petani Kopi',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pengguna Aplikasi',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.greyText,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Informasi Pengguna'),
                  const SizedBox(height: 12),
                  const InfoCard(
                    child: Column(
                      children: [
                        _ProfileInfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Lokasi',
                          value: 'Desa Masewe, Mamasa',
                        ),
                        SizedBox(height: 14),
                        _ProfileInfoRow(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: 'user@example.com',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Statistik Deteksi'),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(label: 'Total Deteksi', value: '25'),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: _StatCard(label: 'Grade A', value: '12')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Grade B', value: '9')),
                      SizedBox(width: 10),
                      Expanded(child: _StatCard(label: 'Grade C', value: '4')),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const InfoCard(
                    child: Text(
                      'Akun ini masih menggunakan data dummy untuk kebutuhan pengujian UI.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DetectionScreen(mode: DetectionMode.camera),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DetectionScreen(mode: DetectionMode.upload),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;
      case 4:
        break;
    }
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryBrown, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryBrown,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
