import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/section_title.dart';
import '../../data/dummy_detection_data.dart';
import '../about/about_screen.dart';
import '../detection/detection_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../result/result_screen.dart';
import 'widgets/detection_action_box.dart';
import 'widgets/feature_menu_card.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_result_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recentResults = dummyDetectionResults.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(onProfileTap: () => _openProfile(context)),
                  const SizedBox(height: 24),
                  DetectionActionBox(
                    onTap: () => _openDetection(context, DetectionMode.camera),
                  ),
                  const SizedBox(height: 26),
                  const SectionTitle(
                    title: 'Menu Utama',
                    subtitle: 'Pilih fitur yang ingin digunakan',
                  ),
                  const SizedBox(height: 14),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 158,
                    ),
                    children: [
                      FeatureMenuCard(
                        title: 'Scan Kamera',
                        subtitle: 'Deteksi langsung',
                        icon: Icons.photo_camera_rounded,
                        accentColor: AppColors.primaryBrown,
                        onTap: () =>
                            _openDetection(context, DetectionMode.camera),
                      ),
                      FeatureMenuCard(
                        title: 'Upload Gambar',
                        subtitle: 'Pilih dari galeri',
                        icon: Icons.upload_file_rounded,
                        accentColor: AppColors.orangeGold,
                        onTap: () =>
                            _openDetection(context, DetectionMode.upload),
                      ),
                      FeatureMenuCard(
                        title: 'Riwayat Deteksi',
                        subtitle: 'Lihat hasil lama',
                        icon: Icons.history_rounded,
                        accentColor: AppColors.green,
                        onTap: () => _openHistory(context),
                      ),
                      FeatureMenuCard(
                        title: 'Tentang Aplikasi',
                        subtitle: 'Info teknologi',
                        icon: Icons.info_rounded,
                        accentColor: AppColors.redAccent,
                        onTap: () => _openAbout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const SectionTitle(title: 'Hasil Terakhir'),
                  const SizedBox(height: 12),
                  for (final result in recentResults)
                    RecentResultCard(
                      result: result,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(result: result),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _openDetection(context, DetectionMode.camera);
        break;
      case 2:
        _openDetection(context, DetectionMode.upload);
        break;
      case 3:
        _openHistory(context);
        break;
      case 4:
        _openProfile(context);
        break;
    }
  }

  void _openDetection(BuildContext context, DetectionMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetectionScreen(mode: mode)),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}
