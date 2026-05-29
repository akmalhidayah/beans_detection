import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/auth_provider_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/local_auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = LocalAuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: const Text('Buat Akun')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthProviderButton(
                    label: 'Daftar dengan Google',
                    google: true,
                    onPressed: _isLoading ? null : _registerWithGoogle,
                  ),
                  const SizedBox(height: 10),
                  AuthProviderButton(
                    label: 'Daftar dengan Nomor Telepon',
                    icon: Icons.phone_android_rounded,
                    onPressed: _isLoading ? null : _registerWithPhone,
                  ),
                  const SizedBox(height: 22),
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
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: Icon(Icons.verified_user_rounded),
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: _isLoading ? 'Menyimpan...' : 'Buat Akun',
                    icon: Icons.person_add_rounded,
                    onPressed: _isLoading ? null : _register,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      _showMessage('Nama wajib diisi.');
      return;
    }
    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password minimal 6 karakter.');
      return;
    }
    if (password != confirm) {
      _showMessage('Konfirmasi password harus sama.');
      return;
    }

    setState(() => _isLoading = true);
    await _authService.register(name: name, email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showMessage('Akun berhasil dibuat.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogleAccount();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showMessage('Akun Google berhasil dibuat.');
    _openHome();
  }

  Future<void> _registerWithPhone() async {
    final profile = await _showProviderDialog(
      title: 'Daftar Nomor Telepon',
      primaryLabel: 'Nomor Telepon',
      primaryIcon: Icons.phone_android_rounded,
      primaryKeyboardType: TextInputType.phone,
    );
    if (profile == null) return;
    if (profile.primary.length < 8) {
      _showMessage('Nomor telepon belum valid.');
      return;
    }

    setState(() => _isLoading = true);
    await _authService.signInWithPhone(
      phone: profile.primary,
      name: profile.name,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showMessage('Akun telepon berhasil dibuat.');
    _openHome();
  }

  Future<_ProviderProfile?> _showProviderDialog({
    required String title,
    required String primaryLabel,
    required IconData primaryIcon,
    required TextInputType primaryKeyboardType,
  }) async {
    final nameController = TextEditingController();
    final primaryController = TextEditingController();
    final value = await showDialog<_ProviderProfile>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: primaryController,
                keyboardType: primaryKeyboardType,
                decoration: InputDecoration(
                  labelText: primaryLabel,
                  prefixIcon: Icon(primaryIcon),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _ProviderProfile(
                    name: nameController.text.trim(),
                    primary: primaryController.text.trim(),
                  ),
                );
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
    primaryController.dispose();
    if (value == null || value.primary.isEmpty) return null;
    return value;
  }

  void _openHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProviderProfile {
  const _ProviderProfile({
    required this.name,
    required this.primary,
  });

  final String name;
  final String primary;
}
