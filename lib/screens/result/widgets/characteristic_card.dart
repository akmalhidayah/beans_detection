import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/info_card.dart';

class CharacteristicCard extends StatelessWidget {
  const CharacteristicCard({super.key, required this.characteristics});

  final Map<String, String> characteristics;

  @override
  Widget build(BuildContext context) {
    final entries = characteristics.entries.toList();
    return InfoCard(
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == entries.length - 1 ? 0 : 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entries[i].key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyText,
                          ),
                    ),
                  ),
                  Text(
                    entries[i].value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
