import 'package:flutter/material.dart';

import '../../../core/widgets/coffee_placeholder.dart';

class DetectionPreviewCard extends StatelessWidget {
  const DetectionPreviewCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CoffeePlaceholder(
      height: 280,
      iconSize: 72,
      title: title,
      subtitle: 'Pastikan biji kopi terlihat jelas dan pencahayaan cukup.',
    );
  }
}
