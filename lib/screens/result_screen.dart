import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_language.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/coffee_placeholder.dart';
import '../core/widgets/confidence_bar.dart';
import '../core/widgets/grade_badge.dart';
import '../core/widgets/info_card.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/secondary_button.dart';
import '../core/widgets/section_title.dart';
import '../models/detection_result.dart';
import '../services/local_auth_service.dart';
import '../services/local_history_service.dart';
import 'detection_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final DetectionResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _authService = LocalAuthService();
  final _historyService = LocalHistoryService();
  String _language = AppLanguage.indonesia;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final currentResult = widget.result;
    final gradeColor = GradeBadge.gradeColor(currentResult.grade);
    final isDetected = currentResult.isDetected;

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        title: Text(AppLanguage.text('classification_result', _language)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BoundingBoxPreview(result: currentResult),
                  const SizedBox(height: 22),
                  if (!isDetected) ...[
                    const _NotDetectedWarning(),
                    const SizedBox(height: 18),
                  ],
                  _ResultSummary(result: currentResult),
                  const SizedBox(height: 22),
                  ConfidenceBar(
                    value: currentResult.confidencePercent,
                    color: gradeColor,
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Karakteristik Fisik'),
                  const SizedBox(height: 12),
                  _CharacteristicCard(
                    characteristics: currentResult.characteristics,
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'Deskripsi Hasil'),
                  const SizedBox(height: 12),
                  InfoCard(child: Text(currentResult.description)),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'Rekomendasi'),
                  const SizedBox(height: 12),
                  InfoCard(child: Text(currentResult.recommendation)),
                  const SizedBox(height: 18),
                  InfoCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.primaryBrown,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Waktu deteksi: ${DateFormatter.format(currentResult.detectedAt)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SecondaryButton(
                    label: AppLanguage.text('save_history', _language),
                    icon: Icons.save_rounded,
                    onPressed: _saveHistory,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: AppLanguage.text('detect_again', _language),
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

  Future<void> _loadLanguage() async {
    final language = await _authService.getLanguage();
    if (!mounted) return;
    setState(() => _language = language);
  }

  Future<void> _saveHistory() async {
    await _historyService.saveResult(widget.result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil deteksi berhasil disimpan ke riwayat.'),
      ),
    );
  }
}

class _BoundingBoxPreview extends StatelessWidget {
  const _BoundingBoxPreview({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    final boxes = result.boundingBoxes;
    final gradeColor = GradeBadge.gradeColor(result.grade);
    final localImagePath = result.imagePath;
    final imageBytes = result.imageBytes;
    final hasMemoryImage = imageBytes != null && imageBytes.isNotEmpty;
    final hasLocalImage =
        !kIsWeb && localImagePath != null && File(localImagePath).existsSync();

    return AspectRatio(
      aspectRatio: 1.42,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return Stack(
              children: [
                Positioned.fill(
                  child: hasMemoryImage
                      ? Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                        )
                      : hasLocalImage
                          ? Image.file(
                              File(localImagePath),
                              fit: BoxFit.cover,
                            )
                          : const CoffeePlaceholder(
                              title: 'Preview hasil deteksi',
                              subtitle: 'Gambar hasil deteksi biji kopi',
                            ),
                ),
                for (final box in boxes) ...[
                  Positioned(
                    left: box.x * width,
                    top: box.y * height,
                    width: box.width * width,
                    height: box.height * height,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: gradeColor, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (box.x * width).clamp(8, width - 120).toDouble(),
                    top: (box.y * height - 30).clamp(8, height - 40).toDouble(),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: width - 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: gradeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${box.label.isEmpty ? result.className : box.label} ${_formatConfidence(box.confidence)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatConfidence(double value) {
    final percent = value <= 1 ? value * 100 : value;
    return '${percent.toStringAsFixed(1)}%';
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    final isDetected = result.isDetected;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isDetected ? result.className : result.status,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (isDetected) GradeBadge(grade: result.grade),
            ],
          ),
          const SizedBox(height: 14),
          _ResultRow(label: 'Jenis kopi', value: result.coffeeType),
          _ResultRow(label: 'Grade kualitas', value: result.grade),
          _ResultRow(label: 'Confidence', value: result.confidenceText),
          _ResultRow(
            label: 'Objek terdeteksi',
            value: result.boundingBoxes.length.toString(),
          ),
          _ResultRow(
            label: 'Status kualitas',
            value: result.status,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _NotDetectedWarning extends StatelessWidget {
  const _NotDetectedWarning();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Objek biji kopi tidak terdeteksi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacteristicCard extends StatelessWidget {
  const _CharacteristicCard({required this.characteristics});

  final Map<String, String> characteristics;

  @override
  Widget build(BuildContext context) {
    final entries = characteristics.entries.toList();
    return InfoCard(
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 12),
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
                      entries[i].key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      entries[i].value,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w900,
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
