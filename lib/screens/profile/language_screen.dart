import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_language.dart';
import '../../services/local_auth_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final _authService = LocalAuthService();
  String _language = AppLanguage.indonesia;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: const Text('Bahasa')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _LanguageTile(
                  label: 'Indonesia',
                  selected: _language == AppLanguage.indonesia,
                  onTap: () => _setLanguage(AppLanguage.indonesia),
                ),
                const SizedBox(height: 12),
                _LanguageTile(
                  label: 'English',
                  selected: _language == AppLanguage.english,
                  onTap: () => _setLanguage(AppLanguage.english),
                ),
              ],
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

  Future<void> _setLanguage(String language) async {
    await _authService.setLanguage(language);
    if (!mounted) return;
    setState(() => _language = language);
    Navigator.pop(context, true);
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.green)
            : const Icon(Icons.circle_outlined, color: AppColors.greyText),
      ),
    );
  }
}
