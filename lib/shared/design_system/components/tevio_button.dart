import 'package:flutter/material.dart';

import '../tokens/tevio_radius.dart';

enum TevioButtonVariant { primary, secondary, danger }

class TevioButton extends StatelessWidget {
  const TevioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = TevioButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final TevioButtonVariant variant;

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

    final style = switch (variant) {
      TevioButtonVariant.primary => FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(
          borderRadius: TevioRadius.mediumBorder,
        ),
      ),
      TevioButtonVariant.secondary => OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(
          borderRadius: TevioRadius.mediumBorder,
        ),
      ),
      TevioButtonVariant.danger => FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: const RoundedRectangleBorder(
          borderRadius: TevioRadius.mediumBorder,
        ),
      ),
    };

    if (variant == TevioButtonVariant.secondary) {
      return OutlinedButton(onPressed: onPressed, style: style, child: child);
    }

    return FilledButton(onPressed: onPressed, style: style, child: child);
  }
}
