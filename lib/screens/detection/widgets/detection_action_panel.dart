import 'package:flutter/material.dart';

import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

class DetectionActionPanel extends StatelessWidget {
  const DetectionActionPanel({
    super.key,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
    required this.onAnalyzePressed,
  });

  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback onSecondaryPressed;
  final VoidCallback onAnalyzePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SecondaryButton(
          label: secondaryLabel,
          icon: secondaryIcon,
          onPressed: onSecondaryPressed,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Analisis Sekarang',
          icon: Icons.analytics_rounded,
          onPressed: onAnalyzePressed,
        ),
      ],
    );
  }
}
