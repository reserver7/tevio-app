import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

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

    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $description, ${selected ? '선택됨' : '선택 안 됨'}',
      child: Material(
        color: TevioColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: TevioRadius.largeBorder,
          child: AnimatedContainer(
            duration: TevioMotion.fast,
            constraints: const BoxConstraints(
              minHeight: TevioDimensions.minTouchTarget,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? TevioThemeColors.selectedSurface(context)
                  : TevioThemeColors.surface(context),
              borderRadius: TevioRadius.largeBorder,
              border: Border.all(
                color: selected
                    ? TevioColors.primary
                    : TevioThemeColors.border(context),
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
                        : TevioThemeColors.secondaryText(context),
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
                  AnimatedSwitcher(
                    duration: TevioMotion.fast,
                    child: Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey(selected),
                      color: selected
                          ? TevioColors.primary
                          : TevioThemeColors.secondaryText(context),
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
