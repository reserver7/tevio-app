import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
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
          borderRadius: TevioRadius.mediumBorder,
          splashFactory: NoSplash.splashFactory,
          splashColor: TevioColors.transparent,
          highlightColor: TevioColors.transparent,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return TevioColors.primary.withValues(alpha: 0.06);
            }
            return TevioColors.transparent;
          }),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: TevioDimensions.minTouchTarget,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? TevioThemeColors.selectedSurface(context)
                  : TevioColors.transparent,
              borderRadius: TevioRadius.mediumBorder,
            ),
            child: Padding(
              padding: const EdgeInsets.all(TevioSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? TevioColors.primary
                          : TevioThemeColors.selectedSurface(context),
                      borderRadius: TevioRadius.mediumBorder,
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                      color: selected
                          ? TevioColors.white
                          : TevioThemeColors.secondaryText(context),
                    ),
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
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? TevioColors.mint
                            : TevioColors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? TevioColors.mint
                              : TevioThemeColors.border(context),
                        ),
                      ),
                      child: Opacity(
                        opacity: selected ? 1 : 0,
                        child: const Icon(
                          Icons.check,
                          size: 15,
                          color: TevioColors.white,
                        ),
                      ),
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
