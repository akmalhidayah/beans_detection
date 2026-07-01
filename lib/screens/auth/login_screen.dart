import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/auth_provider_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/local_auth_service.dart';
import '../home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = LocalAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightCream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 104)),
                  const SizedBox(height: 22),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk mulai klasifikasi biji kopi.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 28),
                  AuthProviderButton(
                    label: 'Masuk dengan Google',
                    google: true,
                    onPressed: _isLoading ? null : _loginWithGoogle,
                  ),
                  const SizedBox(height: 10),
                  AuthProviderButton(
                    label: 'Masuk dengan Nomor Telepon',
                    icon: Icons.phone_android_rounded,
                    onPressed: _isLoading ? null : _loginWithPhone,
                  ),
                  const SizedBox(height: 20),
                  const _DividerLabel(label: 'atau masuk dengan email'),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: _isLoading ? 'Memproses...' : 'Masuk',
                    icon: Icons.login_rounded,
                    onPressed: _isLoading ? null : _login,
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                    child: const Text('Buat Akun'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authService.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      _showMessage('Email atau password tidak sesuai.');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _loginWithGoogle() async {
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
    _openHome();
  }

  Future<void> _loginWithPhone() async {
    final phone = await _showInputDialog(
      title: 'Masuk Nomor Telepon',
      label: 'Nomor Telepon',
      icon: Icons.phone_android_rounded,
      keyboardType: TextInputType.phone,
    );
    if (phone == null) return;
    if (phone.length < 8) {
      _showMessage('Nomor telepon belum valid.');
      return;
    }

    setState(() => _isLoading = true);
    await _authService.signInWithPhone(phone: phone);
    if (!mounted) return;
    setState(() => _isLoading = false);
    _openHome();
  }

  Future<String?> _showInputDialog({
    required String title,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Lanjut'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  void _openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
