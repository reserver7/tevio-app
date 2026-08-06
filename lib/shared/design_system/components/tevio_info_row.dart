import 'package:flutter/material.dart';

import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioInfoRow extends StatelessWidget {
  const TevioInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TevioThemeColors.secondaryText(context),
            ),
          ),
        ),
        const SizedBox(width: TevioSpacing.md),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
