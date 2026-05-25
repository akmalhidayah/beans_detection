import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/app_logo.dart';
import '../services/local_auth_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = LocalAuthService();

  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final isLoggedIn = await _authService.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.05,
            colors: [
              AppColors.white,
              AppColors.creamBackground,
              Color(0xFFEBD3BE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.88 + (0.12 * value),
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 128),
                  const SizedBox(height: 22),
                  Text(
                    'Coffee Quality',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.coffeeDark,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'YOLOv11 Detection',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryBrown,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.coffeeBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
