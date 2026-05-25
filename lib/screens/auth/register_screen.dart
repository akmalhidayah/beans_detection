import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
