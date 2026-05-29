import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_language.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/widgets/coffee_placeholder.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/grade_badge.dart';
import '../models/detection_result.dart';
import '../services/local_auth_service.dart';
import '../services/local_history_service.dart';
import 'detection_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _authService = LocalAuthService();
  final _historyService = LocalHistoryService();

  List<DetectionResult> _results = const [];
  String _query = '';
  String _selectedGrade = 'Semua';
  String _language = AppLanguage.indonesia;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = _results.where((result) {
      final query = _query.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          result.className.toLowerCase().contains(query) ||
          result.coffeeType.toLowerCase().contains(query) ||
          result.grade.toLowerCase().contains(query);
      final matchesGrade =
          _selectedGrade == 'Semua' || result.grade == _selectedGrade;
      return matchesQuery && matchesGrade;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: Text(AppLanguage.text('history', _language))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBrown,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (value) {
                                setState(() => _query = value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari hasil',
                                prefixIcon: const Icon(Icons.search_rounded),
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final grade in const [
                                    'Semua',
                                    'Grade A',
                                    'Grade B',
                                    'Grade C',
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        label: Text(grade),
                                        selected: _selectedGrade == grade,
                                        onSelected: (_) {
                                          setState(() {
                                            _selectedGrade = grade;
                                          });
                                        },
                                        selectedColor: AppColors.cream,
                                        checkmarkColor: AppColors.primaryBrown,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filteredResults.isEmpty
                            ? const EmptyState(
                                title: 'Belum ada riwayat deteksi.',
                                message:
                                    'Simpan hasil klasifikasi dari halaman hasil.',
                                icon: Icons.history_rounded,
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                  itemCount: filteredResults.length,
                                  itemBuilder: (context, index) {
                                    final result = filteredResults[index];
                                    return _HistoryItemCard(
                                      result: result,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ResultScreen(result: result),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        language: _language,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  Future<void> _loadData() async {
    final results = await _historyService.getHistory();
    final language = await _authService.getLanguage();
    if (!mounted) return;
    setState(() {
      _results = results;
      _language = language;
      _isLoading = false;
    });
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

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.result,
    required this.onTap,
  });

  final DetectionResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageBytes = result.imageBytes;
    final hasMemoryImage = imageBytes != null && imageBytes.isNotEmpty;
    final hasLocalImage = !kIsWeb &&
        result.imagePath != null &&
        File(result.imagePath!).existsSync();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: hasMemoryImage
                      ? Image.memory(imageBytes, fit: BoxFit.cover)
                      : hasLocalImage
                          ? Image.file(File(result.imagePath!),
                              fit: BoxFit.cover)
                          : const CoffeePlaceholder(
                              iconSize: 24,
                              title: '',
                              subtitle: '',
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.className,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        if (result.isDetected)
                          GradeBadge(grade: result.grade, compact: true)
                        else
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.redAccent,
                            size: 22,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${result.confidenceText} - ${result.status}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.format(result.detectedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
