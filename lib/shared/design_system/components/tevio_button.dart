import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_theme_colors.dart';

enum TevioButtonVariant { primary, secondary, danger }

enum TevioButtonSize { standard, compact }

class TevioLoadingButton extends StatelessWidget {
  const TevioLoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.variant = TevioButtonVariant.primary,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final TevioButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return TevioButton(
      label: isLoading ? '처리 중' : label,
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? Icons.sync : null,
      variant: variant,
    );
  }
}

class TevioButton extends StatelessWidget {
  const TevioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = TevioButtonVariant.primary,
    this.size = TevioButtonSize.standard,
    this.isExpanded = true,
    this.tooltip,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final TevioButtonVariant variant;
  final TevioButtonSize size;
  final bool isExpanded;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(child: Text(label)),
            ],
          );

    final isDisabled = onPressed == null;
    final height = size == TevioButtonSize.standard
        ? TevioDimensions.buttonHeight
        : TevioDimensions.minTouchTarget;
    final background = switch (variant) {
      TevioButtonVariant.primary => TevioColors.primary,
      TevioButtonVariant.secondary => TevioThemeColors.surface(context),
      TevioButtonVariant.danger => TevioColors.danger,
    };
    final foreground = variant == TevioButtonVariant.secondary
        ? TevioColors.primary
        : Theme.of(context).colorScheme.onPrimary;

    final button = Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: Material(
        color: TevioColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: TevioRadius.mediumBorder,
          child: AnimatedContainer(
            duration: TevioMotion.fast,
            height: height,
            width: isExpanded ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: size == TevioButtonSize.standard ? 18 : 14,
            ),
            decoration: BoxDecoration(
              color: isDisabled
                  ? TevioThemeColors.divider(context)
                  : background,
              borderRadius: TevioRadius.mediumBorder,
              border: variant == TevioButtonVariant.secondary
                  ? Border.all(
                      color: isDisabled
                          ? TevioThemeColors.divider(context)
                          : TevioColors.primary,
                    )
                  : null,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: isDisabled
                    ? TevioThemeColors.secondaryText(context)
                    : foreground,
              ),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isDisabled
                      ? TevioThemeColors.secondaryText(context)
                      : foreground,
                  fontWeight: FontWeight.w800,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
