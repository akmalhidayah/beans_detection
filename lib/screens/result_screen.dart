import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_language.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/image_box_transform.dart';
import '../core/widgets/coffee_placeholder.dart';
import '../core/widgets/empty_state.dart';
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
    final isDetected = currentResult.isDetected;

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        title: Text(AppLanguage.text('classification_result', _language)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 700;
            final maxWidth = constraints.maxWidth >= 1100
                ? 960.0
                : isTablet
                    ? 880.0
                    : 560.0;
            final horizontalPadding = isTablet ? 28.0 : 18.0;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    32,
                  ),
                  child: isDetected
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BoundingBoxPreview(result: currentResult),
                            const SizedBox(height: 20),
                            _ResultSummary(result: currentResult),
                            const SizedBox(height: 16),
                            _CompositionCard(result: currentResult),
                            const SizedBox(height: 24),
                            _SectionHeading(
                              title: 'Karakteristik Umum Berdasarkan Grade',
                              onInfo: _showCharacteristicsInfo,
                            ),
                            const SizedBox(height: 12),
                            _CharacteristicCard(
                              characteristics: currentResult.characteristics,
                            ),
                            const SizedBox(height: 18),
                            _InformationResultTile(onTap: _showResultInfo),
                            const SizedBox(height: 22),
                            const SectionTitle(title: 'Rekomendasi'),
                            const SizedBox(height: 12),
                            _RecommendationCard(result: currentResult),
                            const SizedBox(height: 16),
                            _DetectionTime(result: currentResult),
                            const SizedBox(height: 24),
                            _ResponsiveResultActions(
                              language: _language,
                              onSave: _saveHistory,
                              onDetectAgain: _detectAgain,
                              onHome: _goHome,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            EmptyState(
                              title: 'Tidak ada biji kopi terdeteksi.',
                              message: currentResult.message.isNotEmpty
                                  ? currentResult.message
                                  : 'Silakan ambil gambar ulang dengan pencahayaan yang cukup dan objek biji kopi terlihat jelas.',
                              icon: Icons.search_off_rounded,
                            ),
                            PrimaryButton(
                              label:
                                  AppLanguage.text('detect_again', _language),
                              icon: Icons.refresh_rounded,
                              onPressed: _detectAgain,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
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
    if (!widget.result.isDetected) return;
    final user = await _authService.getUser();
    await _historyService.saveResult(
      widget.result,
      userId: user.id,
      email: user.email,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil deteksi berhasil disimpan ke riwayat.'),
      ),
    );
  }

  void _detectAgain() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DetectionScreen(mode: DetectionMode.camera),
        ),
      );

  void _goHome() => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );

  void _showCharacteristicsInfo() => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tentang Karakteristik'),
          content: const Text(
            'Karakteristik berikut merupakan gambaran umum sesuai grade hasil klasifikasi. Informasi ini bukan hasil pengukuran warna, ukuran, permukaan, atau keutuhan secara terpisah oleh model.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );

  void _showResultInfo() {
    final description = widget.result.description.trim();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cara Hasil Ditentukan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              Text(
                description.isNotEmpty && description != '-'
                    ? description
                    : 'Hasil klasifikasi keseluruhan ditentukan dari kelas dengan jumlah objek terdeteksi paling banyak. Nilai confidence merupakan rata-rata confidence objek pada kelas tersebut.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Hasil hanya ditampilkan apabila tingkat keyakinan model memenuhi batas minimum yang ditetapkan sistem.',
              ),
            ],
          ),
        ),
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
    final localImagePath = result.imagePath;
    final imageBytes = result.imageBytes;
    final hasMemoryImage = imageBytes != null && imageBytes.isNotEmpty;
    final hasLocalImage =
        !kIsWeb && localImagePath != null && File(localImagePath).existsSync();

    final imageData = hasMemoryImage
        ? imageBytes
        : hasLocalImage
            ? File(localImagePath).readAsBytesSync()
            : null;
    return AspectRatio(
      aspectRatio: 1.42,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return FutureBuilder<Size?>(
              future:
                  imageData == null ? Future.value() : _imageSize(imageData),
              builder: (context, snapshot) {
                final imageSize = snapshot.data;
                final imageRect = imageSize == null
                    ? Offset.zero & Size(width, height)
                    : containedImageRect(
                        imageSize: imageSize,
                        viewportSize: Size(width, height),
                      );
                return Stack(
                  children: [
                    Positioned.fill(
                      child: hasMemoryImage
                          ? Image.memory(
                              imageBytes,
                              fit: BoxFit.contain,
                            )
                          : hasLocalImage
                              ? Image.file(
                                  File(localImagePath),
                                  fit: BoxFit.contain,
                                )
                              : const CoffeePlaceholder(
                                  title: 'Preview hasil deteksi',
                                  subtitle: 'Gambar hasil deteksi biji kopi',
                                ),
                    ),
                    if (imageData != null)
                      for (final box in boxes) ...[
                        Positioned(
                          left: boundingBoxRect(box, imageRect).left,
                          top: boundingBoxRect(box, imageRect).top,
                          width: boundingBoxRect(box, imageRect).width,
                          height: boundingBoxRect(box, imageRect).height,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: GradeBadge.gradeColor(
                                  box.grade.isEmpty ? result.grade : box.grade,
                                ),
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Positioned(
                          left: boundingBoxRect(box, imageRect)
                              .left
                              .clamp(
                                imageRect.left + 8,
                                (imageRect.right - 120).clamp(
                                  imageRect.left + 8,
                                  imageRect.right,
                                ),
                              )
                              .toDouble(),
                          top: (boundingBoxRect(box, imageRect).top - 30)
                              .clamp(
                                imageRect.top + 8,
                                (imageRect.bottom - 40).clamp(
                                  imageRect.top + 8,
                                  imageRect.bottom,
                                ),
                              )
                              .toDouble(),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: width - 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: GradeBadge.gradeColor(
                                box.grade.isEmpty ? result.grade : box.grade,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${box.label.isEmpty ? (box.className.isEmpty ? result.className : box.className) : box.label} ${_formatConfidence(box.confidence)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
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
            );
          },
        ),
      ),
    );
  }

  Future<Size?> _imageSize(Uint8List bytes) async {
    try {
      final image = await decodeImageFromList(bytes);
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    } catch (_) {
      return null;
    }
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
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.className,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              GradeBadge(grade: result.grade),
            ],
          ),
          const SizedBox(height: 18),
          _ResultMetricGrid(
            metrics: [
              _ResultMetric(
                icon: Icons.shield_outlined,
                label: 'Confidence',
                value: result.confidenceText,
              ),
              _ResultMetric(
                icon: Icons.center_focus_strong_rounded,
                label: 'Objek terdeteksi',
                value: result.totalDetected.toString(),
              ),
              _ResultMetric(
                icon: Icons.filter_alt_outlined,
                label: 'Perlu disortasi',
                value:
                    '${result.summary.sortingRequiredPercentage.toStringAsFixed(1)}%',
              ),
              _ResultMetric(
                icon: Icons.workspace_premium_outlined,
                label: 'Status kualitas',
                value: result.status,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultMetric {
  const _ResultMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _ResultMetricGrid extends StatelessWidget {
  const _ResultMetricGrid({required this.metrics});

  final List<_ResultMetric> metrics;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 460 ? 2 : 1;
          final itemWidth = columns == 2
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: itemWidth,
                  child: _ResultMetricItem(metric: metric),
                ),
            ],
          );
        },
      );
}

class _ResultMetricItem extends StatelessWidget {
  const _ResultMetricItem({required this.metric});

  final _ResultMetric metric;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(metric.icon, size: 21, color: AppColors.primaryBrown),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.greyText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _CharacteristicCard extends StatelessWidget {
  const _CharacteristicCard({required this.characteristics});

  final Map<String, String> characteristics;

  @override
  Widget build(BuildContext context) {
    final entries = characteristics.entries.toList();
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatCharacteristicKey(entries[i].key),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
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

class _CompositionCard extends StatelessWidget {
  const _CompositionCard({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    final entries = result.summary.classCounts.entries
        .where((entry) => entry.value > 0)
        .toList();
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komposisi hasil deteksi',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < entries.length; i++) ...[
            _CompositionItem(
              className: entries[i].key,
              count: entries[i].value,
              total: result.summary.total,
            ),
            if (i != entries.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _CompositionItem extends StatelessWidget {
  const _CompositionItem({
    required this.className,
    required this.count,
    required this.total,
  });

  final String className;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : count / total * 100;
    final grade = className.contains('Grade A')
        ? 'Grade A'
        : className.contains('Grade B')
            ? 'Grade B'
            : 'Grade C';
    final color = GradeBadge.gradeColor(grade);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                className,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Text('$count objek',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: (percentage / 100).clamp(0, 1),
            color: color,
            backgroundColor: AppColors.line,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.onInfo});

  final String title;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          IconButton(
            tooltip: 'Informasi karakteristik',
            onPressed: onInfo,
            icon: const Icon(Icons.info_outline_rounded),
            color: AppColors.primaryBrown,
          ),
        ],
      );
}

class _InformationResultTile extends StatelessWidget {
  const _InformationResultTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primaryBrown),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informasi hasil',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      SizedBox(height: 2),
                      Text(
                        'Cara penentuan hasil klasifikasi',
                        style: TextStyle(color: AppColors.greyText),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.greyText),
              ],
            ),
          ),
        ),
      );
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) {
    final color = GradeBadge.gradeColor(result.grade);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.recommendation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rekomendasi dibuat oleh aturan sistem berdasarkan hasil klasifikasi.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}

class _DetectionTime extends StatelessWidget {
  const _DetectionTime({required this.result});

  final DetectionResult result;

  @override
  Widget build(BuildContext context) => InfoCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded, color: AppColors.primaryBrown),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Waktu deteksi: ${DateFormatter.format(result.detectedAt)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}

class _ResponsiveResultActions extends StatelessWidget {
  const _ResponsiveResultActions({
    required this.language,
    required this.onSave,
    required this.onDetectAgain,
    required this.onHome,
  });

  final String language;
  final VoidCallback onSave;
  final VoidCallback onDetectAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final buttons = [
            SecondaryButton(
              label: AppLanguage.text('save_history', language),
              icon: Icons.save_rounded,
              onPressed: onSave,
            ),
            PrimaryButton(
              label: AppLanguage.text('detect_again', language),
              icon: Icons.refresh_rounded,
              onPressed: onDetectAgain,
            ),
            SecondaryButton(
              label: 'Kembali ke Beranda',
              icon: Icons.home_rounded,
              onPressed: onHome,
            ),
          ];
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < buttons.length; i++) ...[
                  Expanded(child: buttons[i]),
                  if (i != buttons.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          }
          return Column(
            children: [
              for (var i = 0; i < buttons.length; i++) ...[
                buttons[i],
                if (i != buttons.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        },
      );
}

String _formatCharacteristicKey(String key) {
  if (key == 'bentuk_keutuhan') return 'Bentuk & Keutuhan';
  final words = key.replaceAll('_', ' ').trim().split(RegExp(r'\s+'));
  return words
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
