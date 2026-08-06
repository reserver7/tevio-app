import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioChoiceChip extends StatelessWidget {
  const TevioChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: TevioRadius.fullBorder,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: TevioSpacing.md,
            vertical: TevioSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? TevioColors.primary
                : TevioThemeColors.surface(context),
            borderRadius: TevioRadius.fullBorder,
            border: Border.all(
              color: selected
                  ? TevioColors.primary
                  : TevioThemeColors.border(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? TevioColors.white
                      : TevioThemeColors.secondaryText(context),
                ),
                const SizedBox(width: TevioSpacing.xs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? TevioColors.white
                      : TevioThemeColors.secondaryText(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
