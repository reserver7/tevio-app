import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioSegmentedControl<T> extends StatelessWidget {
  const TevioSegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
  });

  final List<T> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T item) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TevioColors.divider,
          borderRadius: TevioRadius.mediumBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(item),
                    borderRadius: TevioRadius.smallBorder,
                    child: Semantics(
                      button: true,
                      selected: item == selected,
                      label: labelBuilder(item),
                      child: AnimatedContainer(
                        duration: TevioMotion.fast,
                        padding: const EdgeInsets.symmetric(
                          vertical: TevioSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: item == selected
                              ? TevioThemeColors.surface(context)
                              : TevioColors.transparent,
                          borderRadius: TevioRadius.smallBorder,
                        ),
                        child: Text(
                          labelBuilder(item),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: item == selected
                                    ? TevioThemeColors.primaryText(context)
                                    : TevioThemeColors.secondaryText(context),
                                fontWeight: FontWeight.w800,
                              ),
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
  }
}
