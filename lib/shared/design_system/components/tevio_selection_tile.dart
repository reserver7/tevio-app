import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';

class TevioSelectionTile extends StatelessWidget {
  const TevioSelectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: TevioColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TevioRadius.largeBorder,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? TevioColors.primaryBackground
                : TevioColors.surface,
            borderRadius: TevioRadius.largeBorder,
            border: Border.all(
              color: selected ? TevioColors.primary : TevioColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TevioSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? TevioColors.primary
                      : TevioColors.textTertiary,
                ),
                const SizedBox(width: TevioSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium),
                      const SizedBox(height: TevioSpacing.xxs),
                      Text(description, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: TevioSpacing.sm),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected
                      ? TevioColors.primary
                      : TevioColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
