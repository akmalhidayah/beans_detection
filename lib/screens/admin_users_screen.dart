import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/rounded_card.dart';
import '../models/admin_user_model.dart';
import '../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _adminService = AdminService();

  List<AdminUserModel> _users = const [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(
        title: const Text('User Aktif'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadUsers,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
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
                : _errorMessage.isNotEmpty
                    ? EmptyState(
                        title: 'Tidak dapat memuat user.',
                        message: _errorMessage,
                        icon: Icons.admin_panel_settings_rounded,
                      )
                    : _users.isEmpty
                        ? const EmptyState(
                            title: 'Belum ada user terdaftar.',
                            message: 'User yang terdaftar akan tampil di sini.',
                            icon: Icons.people_alt_rounded,
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 24),
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                return _AdminUserCard(user: _users[index]);
                              },
                            ),
                          ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final users = await _adminService.fetchUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }
}

class _AdminUserCard extends StatelessWidget {
  const _AdminUserCard({required this.user});

  final AdminUserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RoundedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(isOnline: user.isOnline),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(label: 'Role', value: user.role),
            _InfoRow(
              label: 'Status akun',
              value: user.isActive ? 'Aktif' : 'Nonaktif',
            ),
            _InfoRow(
              label: 'Last login',
              value: _formatDate(user.lastLoginAt),
            ),
            _InfoRow(
              label: 'Last seen',
              value: _formatDate(user.lastSeenAt),
            ),
            _InfoRow(
              label: 'Total deteksi',
              value: user.totalPredictions.toString(),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return DateFormatter.format(value);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.green : AppColors.greyText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOnline ? 'Online' : 'Offline',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
