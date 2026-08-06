import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_theme_colors.dart';

enum TevioIconButtonVariant { plain, filled, tinted, danger }

class TevioIconButton extends StatelessWidget {
  const TevioIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.variant = TevioIconButtonVariant.plain,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final TevioIconButtonVariant variant;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final color = disabled
        ? TevioThemeColors.secondaryText(context)
        : variant == TevioIconButtonVariant.danger
        ? TevioColors.danger
        : TevioColors.primary;
    final background = switch (variant) {
      TevioIconButtonVariant.plain => TevioColors.transparent,
      TevioIconButtonVariant.filled => TevioThemeColors.surface(context),
      TevioIconButtonVariant.tinted => TevioThemeColors.selectedSurface(
        context,
      ),
      TevioIconButtonVariant.danger => TevioColors.dangerBackground,
    };

    return Semantics(
      button: true,
      enabled: !disabled,
      selected: selected,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: TevioColors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: TevioRadius.fullBorder,
            child: AnimatedContainer(
              duration: TevioMotion.fast,
              width: TevioDimensions.minTouchTarget,
              height: TevioDimensions.minTouchTarget,
              decoration: BoxDecoration(
                color: disabled ? TevioColors.divider : background,
                borderRadius: TevioRadius.fullBorder,
                border: selected
                    ? Border.all(color: TevioColors.primary)
                    : null,
              ),
              child: Icon(icon, color: color, size: TevioDimensions.iconLarge),
            ),
          ),
        ),
      ),
    );
  }
}
