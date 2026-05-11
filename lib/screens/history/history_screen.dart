import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/dummy_detection_data.dart';
import '../detection/detection_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../result/result_screen.dart';
import 'widgets/history_item_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = dummyDetectionResults;
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: const Text('Riwayat Deteksi')),
      body: SafeArea(
        child: results.isEmpty
            ? const EmptyState(
                title: 'Belum ada riwayat',
                message: 'Hasil deteksi yang disimpan akan muncul di sini.',
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return HistoryItemCard(
                        result: result,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultScreen(result: result),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
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
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
}
