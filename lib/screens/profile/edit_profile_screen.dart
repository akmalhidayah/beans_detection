import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/local_auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = LocalAuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: const Text('Edit Profil')),
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Lokasi',
                            prefixIcon: Icon(Icons.location_on_rounded),
                          ),
                        ),
                        const SizedBox(height: 22),
                        PrimaryButton(
                          label: 'Simpan',
                          icon: Icons.save_rounded,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadProfile() async {
    final user = await _authService.getUser();
    if (!mounted) return;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _locationController.text = user.location;
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || email.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi.')),
      );
      return;
    }

    await _authService.updateProfile(
      name: name,
      email: email,
      location: location,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
