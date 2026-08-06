import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioTabs<T> extends StatelessWidget {
  const TevioTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  final List<T> items;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in items)
              Semantics(
                button: true,
                inMutuallyExclusiveGroup: true,
                selected: item == selected,
                label: labelBuilder(item),
                child: InkWell(
                  onTap: () => onChanged(item),
                  child: AnimatedContainer(
                    duration: TevioMotion.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: TevioSpacing.md,
                      vertical: TevioSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: item == selected
                              ? TevioColors.primary
                              : TevioColors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      labelBuilder(item),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: item == selected
                            ? TevioColors.primary
                            : TevioThemeColors.secondaryText(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
