import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioCard extends StatefulWidget {
  const TevioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(TevioSpacing.lg),
    this.onTap,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accentColor;

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
          color: TevioThemeColors.surface(context),
          borderRadius: TevioRadius.largeBorder,
          border: Border.all(color: TevioThemeColors.border(context)),
        ),
        child: Material(
          color: TevioColors.transparent,
          child: Stack(
            children: [
              Padding(padding: widget.padding, child: widget.child),
              if (widget.accentColor != null)
                Positioned.fill(
                  left: 0,
                  top: 12,
                  bottom: 12,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: TevioDimensions.statusRail,
                      height: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: TevioRadius.fullBorder,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.onTap == null) return content;

    return Semantics(
      button: true,
      enabled: true,
      child: AnimatedScale(
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
      ),
    );
  }
}
