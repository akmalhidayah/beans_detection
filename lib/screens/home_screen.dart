import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_language.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/grade_badge.dart';
import '../core/widgets/menu_card.dart';
import '../core/widgets/rounded_card.dart';
import '../core/widgets/section_title.dart';
import '../core/widgets/stat_card.dart';
import '../models/detection_result.dart';
import '../services/local_auth_service.dart';
import '../services/local_history_service.dart';
import 'detection_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = LocalAuthService();
  final _historyService = LocalHistoryService();

  LocalUser? _user;
  List<DetectionResult> _history = const [];
  String _language = AppLanguage.indonesia;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final name = user?.name ?? 'Petani Kopi';
    final latestResult = _history.isEmpty ? null : _history.first;

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
                child: _isLoading
                    ? const SizedBox(
                        height: 420,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBrown,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HomeHeader(
                            name: name,
                            onProfileTap: () => _openProfile(context),
                          ),
                          const SizedBox(height: 22),
                          _StatsGrid(results: _history),
                          const SizedBox(height: 26),
                          const SectionTitle(title: 'Menu Utama'),
                          const SizedBox(height: 14),
                          _MenuGrid(
                            onScan: () => _openDetection(
                              context,
                              DetectionMode.camera,
                            ),
                            onUpload: () => _openDetection(
                              context,
                              DetectionMode.upload,
                            ),
                            onHistory: () => _openHistory(context),
                            onProfile: () => _openProfile(context),
                          ),
                          const SizedBox(height: 26),
                          const SectionTitle(title: 'Deteksi Terakhir'),
                          const SizedBox(height: 12),
                          if (latestResult == null)
                            const EmptyState(
                              title: 'Belum ada deteksi.',
                              message:
                                  'Hasil yang disimpan akan tampil di sini.',
                              icon: Icons.coffee_rounded,
                            )
                          else
                            _LatestResultCard(
                              result: latestResult,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResultScreen(
                                    result: latestResult,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        language: _language,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  Future<void> _loadData() async {
    final user = await _authService.getUser();
    final history = await _historyService.getHistory();
    if (!mounted) return;
    setState(() {
      _user = user;
      _history = history;
      _language = user.language;
      _isLoading = false;
    });
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
    ).then((_) => _loadData());
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    ).then((_) => _loadData());
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) => _loadData());
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.onProfileTap,
  });

  final String name;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                'Cek kualitas kopi hari ini',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(16),
          child: const AppLogo(
            size: 52,
            withShadow: false,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.results});

  final List<DetectionResult> results;

  @override
  Widget build(BuildContext context) {
    final gradeA = results.where((result) => result.grade == 'Grade A').length;
    final gradeB = results.where((result) => result.grade == 'Grade B').length;
    final gradeC = results.where((result) => result.grade == 'Grade C').length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.34,
      children: [
        StatCard(
          label: 'Total Deteksi',
          value: results.length.toString(),
          icon: Icons.analytics_rounded,
        ),
        StatCard(
          label: 'Grade A',
          value: gradeA.toString(),
          icon: Icons.workspace_premium_rounded,
          color: AppColors.green,
        ),
        StatCard(
          label: 'Grade B',
          value: gradeB.toString(),
          icon: Icons.verified_rounded,
          color: AppColors.orangeGold,
        ),
        StatCard(
          label: 'Grade C',
          value: gradeC.toString(),
          icon: Icons.report_rounded,
          color: AppColors.redAccent,
        ),
      ],
    );
  }
}

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.onScan,
    required this.onUpload,
    required this.onHistory,
    required this.onProfile,
  });

  final VoidCallback onScan;
  final VoidCallback onUpload;
  final VoidCallback onHistory;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 146,
      ),
      children: [
        MenuCard(
          title: 'Scan Kamera',
          subtitle: 'Deteksi langsung',
          icon: Icons.photo_camera_rounded,
          color: AppColors.primaryBrown,
          onTap: onScan,
        ),
        MenuCard(
          title: 'Upload Gambar',
          subtitle: 'Pilih galeri',
          icon: Icons.upload_file_rounded,
          color: AppColors.warmGold,
          onTap: onUpload,
        ),
        MenuCard(
          title: 'Riwayat',
          subtitle: 'Hasil tersimpan',
          icon: Icons.history_rounded,
          color: AppColors.oliveGreen,
          onTap: onHistory,
        ),
        MenuCard(
          title: 'Profil',
          subtitle: 'Akun pengguna',
          icon: Icons.person_rounded,
          color: AppColors.redAccent,
          onTap: onProfile,
        ),
      ],
    );
  }
}

class _LatestResultCard extends StatelessWidget {
  const _LatestResultCard({
    required this.result,
    required this.onTap,
  });

  final DetectionResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.coffee_rounded,
              color: AppColors.primaryBrown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w900,
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
          if (result.isDetected)
            GradeBadge(grade: result.grade, compact: true)
          else
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.redAccent,
            ),
        ],
      ),
    );
  }
}
