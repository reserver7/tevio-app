import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_shadows.dart';
import '../tokens/tevio_spacing.dart';

class TevioCard extends StatelessWidget {
  const TevioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TevioSpacing.lg),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: TevioRadius.largeBorder,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TevioColors.surface,
          borderRadius: TevioRadius.largeBorder,
          border: Border.all(color: TevioColors.border),
          boxShadow: TevioShadows.card,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: TevioColors.transparent,
      borderRadius: TevioRadius.largeBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: TevioRadius.largeBorder,
        child: content,
      ),
    );
  }
}
