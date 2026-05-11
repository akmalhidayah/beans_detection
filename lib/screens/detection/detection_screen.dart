import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/section_title.dart';
import '../../data/dummy_detection_data.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../result/result_screen.dart';
import 'widgets/detection_action_panel.dart';
import 'widgets/detection_preview_card.dart';

enum DetectionMode { camera, upload }

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({
    super.key,
    this.mode = DetectionMode.camera,
  });

  final DetectionMode mode;

  @override
  Widget build(BuildContext context) {
    final isCameraMode = mode == DetectionMode.camera;
    final title = isCameraMode ? 'Scan Kamera' : 'Upload Gambar';
    final previewTitle = isCameraMode
        ? 'Preview kamera biji kopi'
        : 'Preview gambar dari galeri';
    final secondaryLabel = isCameraMode ? 'Ambil Gambar' : 'Pilih Gambar';
    final secondaryIcon =
        isCameraMode ? Icons.camera_alt_rounded : Icons.photo_library_rounded;
    final message = isCameraMode
        ? 'Fitur kamera akan disambungkan pada tahap berikutnya'
        : 'Fitur galeri akan disambungkan pada tahap berikutnya';

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Preview Deteksi',
                    subtitle: 'Gunakan gambar placeholder untuk tahap UI awal',
                  ),
                  const SizedBox(height: 14),
                  DetectionPreviewCard(title: previewTitle),
                  const SizedBox(height: 22),
                  DetectionActionPanel(
                    secondaryLabel: secondaryLabel,
                    secondaryIcon: secondaryIcon,
                    onSecondaryPressed: () => _showMessage(context, message),
                    onAnalyzePressed: () => _analyze(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: isCameraMode ? 1 : 2,
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
        if (mode != DetectionMode.camera) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DetectionScreen(mode: DetectionMode.camera),
            ),
          );
        }
        break;
      case 2:
        if (mode != DetectionMode.upload) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DetectionScreen(mode: DetectionMode.upload),
            ),
          );
        }
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _analyze(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AnalysisLoadingDialog(),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!context.mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: dummyDetectionResults.first),
      ),
    );
  }
}

class _AnalysisLoadingDialog extends StatelessWidget {
  const _AnalysisLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBrown),
            SizedBox(height: 18),
            Text(
              'Sedang menganalisis biji kopi...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
