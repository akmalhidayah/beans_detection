import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_language.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.language = AppLanguage.indonesia,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String language;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBrown.withValues(alpha: 0.13),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.white,
                  selectedItemColor: AppColors.primaryBrown,
                  unselectedItemColor: AppColors.greyText,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  elevation: 0,
                  onTap: onTap,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home_rounded),
                      label: AppLanguage.text('home', language),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.center_focus_strong_rounded),
                      label: AppLanguage.text('scan', language),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.add_circle_rounded),
                      label: AppLanguage.text('upload', language),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.history_rounded),
                      label: AppLanguage.text('history', language),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person_rounded),
                      label: AppLanguage.text('profile', language),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
