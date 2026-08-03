import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_language.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/widgets/backend_status_chip.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/rounded_card.dart';
import '../core/widgets/secondary_button.dart';
import '../core/widgets/section_title.dart';
import '../core/widgets/stat_card.dart';
import '../models/detection_result.dart';
import '../services/local_auth_service.dart';
import '../services/local_history_service.dart';
import '../services/model_management_service.dart';
import '../services/prediction_api_service.dart';
import 'admin_users_screen.dart';
import 'auth/login_screen.dart';
import 'detection_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/language_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = LocalAuthService();
  final _historyService = LocalHistoryService();
  final _apiService = PredictionApiService();
  final _modelService = ModelManagementService();

  LocalUser? _user;
  List<DetectionResult> _history = const [];
  bool _backendOnline = false;
  bool _isLoading = true;
  bool _isUploadingModel = false;

  String get _language => _user?.language ?? AppLanguage.indonesia;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final mostFrequentGrade = _mostFrequentGrade();

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: Text(AppLanguage.text('profile', _language))),
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
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: BackendStatusChip(
                              isOnline: _backendOnline,
                              language: _language,
                              onRefresh: _refreshBackendStatus,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Column(
                              children: [
                                const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.cream,
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryBrown,
                                    size: 54,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  user?.name ?? 'Petani Kopi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppColors.darkText,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'user@example.com',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.greyText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          RoundedCard(
                            child: Column(
                              children: [
                                _InfoRow(
                                  icon: Icons.location_on_rounded,
                                  label: 'Lokasi',
                                  value: user?.location ?? '-',
                                ),
                                const SizedBox(height: 14),
                                _InfoRow(
                                  icon: Icons.language_rounded,
                                  label:
                                      AppLanguage.text('language', _language),
                                  value:
                                      user?.language ?? AppLanguage.indonesia,
                                ),
                                const SizedBox(height: 14),
                                _InfoRow(
                                  icon: Icons.admin_panel_settings_rounded,
                                  label: 'Role',
                                  value: user?.role ?? 'user',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const SectionTitle(title: 'Statistik'),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.24,
                            children: [
                              StatCard(
                                label: 'Total Deteksi',
                                value: _history.length.toString(),
                                icon: Icons.analytics_rounded,
                              ),
                              StatCard(
                                label: 'Grade Paling Sering',
                                value: mostFrequentGrade,
                                icon: Icons.workspace_premium_rounded,
                                color: AppColors.green,
                              ),
                            ],
                          ),
                          if (user?.isAdmin == true) ...[
                            const SizedBox(height: 24),
                            const SectionTitle(title: 'Menu Admin'),
                            const SizedBox(height: 12),
                            RoundedCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    icon: Icons.memory_rounded,
                                    label: 'Model aktif',
                                    value: 'models/best.pt',
                                  ),
                                  const SizedBox(height: 14),
                                  SecondaryButton(
                                    label: _isUploadingModel
                                        ? 'Mengunggah model...'
                                        : 'Upload Model .pt',
                                    icon: Icons.cloud_upload_rounded,
                                    onPressed:
                                        _isUploadingModel ? null : _uploadModel,
                                  ),
                                  const SizedBox(height: 12),
                                  SecondaryButton(
                                    label: 'User Aktif',
                                    icon: Icons.people_alt_rounded,
                                    onPressed: _openAdminUsers,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: AppLanguage.text('edit_profile', _language),
                            icon: Icons.edit_rounded,
                            onPressed: _editProfile,
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: AppLanguage.text('language', _language),
                            icon: Icons.language_rounded,
                            onPressed: _openLanguage,
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: AppLanguage.text('logout', _language),
                            icon: Icons.logout_rounded,
                            onPressed: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 4,
        language: _language,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  Future<void> _loadData() async {
    final user = await _authService.getUser();
    final history = await _historyService.getHistory(
      userId: user.id,
      email: user.email,
    );
    final online = await _apiService.checkHealth();
    if (!mounted) return;
    setState(() {
      _user = user;
      _history = history;
      _backendOnline = online;
      _isLoading = false;
    });
  }

  Future<void> _refreshBackendStatus() async {
    final online = await _apiService.checkHealth();
    if (!mounted) return;
    setState(() => _backendOnline = online);
  }

  String _mostFrequentGrade() {
    final detected = _history.where((result) => result.isDetected);
    final counts = <String, int>{};
    for (final result in detected) {
      counts[result.grade] = (counts[result.grade] ?? 0) + 1;
    }
    if (counts.isEmpty) return '-';
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Future<void> _editProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (!mounted) return;
    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
      _loadData();
    }
  }

  Future<void> _openLanguage() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
    if (updated == true) {
      _loadData();
    }
  }

  Future<void> _uploadModel() async {
    final user = _user;
    if (user?.isAdmin != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Akses ditolak. Hanya admin yang dapat mengunggah model.'),
        ),
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pt'],
      withData: kIsWeb,
    );
    final file = result?.files.single;
    if (file == null) return;

    setState(() => _isUploadingModel = true);
    try {
      await _modelService.uploadModel(file);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model berhasil diperbarui.')),
      );
      _refreshBackendStatus();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingModel = false);
      }
    }
  }

  Future<void> _openAdminUsers() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
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
