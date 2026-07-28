import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';

class TevioCard extends StatefulWidget {
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
  State<TevioCard> createState() => _TevioCardState();
}

class _TevioCardState extends State<TevioCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: TevioRadius.largeBorder,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TevioColors.surface,
          borderRadius: TevioRadius.largeBorder,
          border: Border.all(color: TevioColors.border),
        ),
        child: Material(
          color: TevioColors.transparent,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    if (widget.onTap == null) {
      return content;
    }

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: TevioMotion.fast,
      curve: TevioMotion.pressCurve,
      child: Material(
        color: TevioColors.transparent,
        borderRadius: TevioRadius.largeBorder,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          borderRadius: TevioRadius.largeBorder,
          child: content,
        ),
      ),
    );
  }
}
