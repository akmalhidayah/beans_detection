import 'package:flutter/material.dart';

import '../../core/widgets/info_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/section_title.dart';
import '../../data/dummy_detection_data.dart';
import '../../models/detection_result.dart';
import '../detection/detection_screen.dart';
import '../home/home_screen.dart';
import 'widgets/bounding_box_preview.dart';
import 'widgets/characteristic_card.dart';
import 'widgets/result_header_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.result});

  final DetectionResult? result;

  @override
  Widget build(BuildContext context) {
    final currentResult = result ?? dummyDetectionResults.first;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(title: const Text('Hasil Deteksi')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoundingBoxPreview(result: currentResult),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Ringkasan Hasil'),
                  const SizedBox(height: 12),
                  ResultHeaderCard(result: currentResult),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'Keterangan'),
                  const SizedBox(height: 12),
                  InfoCard(child: Text(currentResult.description)),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'Detail Karakteristik'),
                  const SizedBox(height: 12),
                  CharacteristicCard(
                    characteristics: currentResult.characteristics,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Scan Ulang',
                    icon: Icons.refresh_rounded,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DetectionScreen(
                          mode: DetectionMode.camera,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Simpan ke Riwayat',
                    icon: Icons.save_rounded,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hasil berhasil disimpan ke riwayat'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Kembali ke Beranda',
                    icon: Icons.home_rounded,
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
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
