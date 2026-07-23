import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';

class TevioCard extends StatelessWidget {
  const TevioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TevioSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: TevioColors.surface,
        borderRadius: TevioRadius.largeBorder,
        border: Border.all(color: TevioColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1E3A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TevioRadius.largeBorder,
        child: content,
      ),
    );
  }
}
