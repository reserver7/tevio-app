import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioFormSection extends StatelessWidget {
  const TevioFormSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (description != null) ...[
          const SizedBox(height: TevioSpacing.xs),
          Text(description!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: TevioSpacing.md),
        child,
      ],
    );
  }
}

class TevioFilterBar<T> extends StatelessWidget {
  const TevioFilterBar({
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
    return SizedBox(
      height: TevioDimensions.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: TevioSpacing.xs),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: labelBuilder(item),
            child: InkWell(
              onTap: () => onChanged(item),
              borderRadius: TevioRadius.fullBorder,
              child: AnimatedContainer(
                duration: TevioMotion.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: TevioSpacing.md,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? TevioColors.primary
                      : TevioThemeColors.surface(context),
                  borderRadius: TevioRadius.fullBorder,
                  border: Border.all(
                    color: isSelected
                        ? TevioColors.primary
                        : TevioThemeColors.border(context),
                  ),
                ),
                child: Text(
                  labelBuilder(item),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? TevioColors.white
                        : TevioThemeColors.secondaryText(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TevioDialog extends StatelessWidget {
  const TevioDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = '확인',
    this.cancelLabel = '취소',
    this.onConfirm,
    this.isDestructive = false,
    this.confirmEnabled = true,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final bool isDestructive;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      namesRoute: true,
      label: title,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: TevioRadius.largeBorder,
        ),
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: !confirmEnabled
                ? null
                : () {
                    onConfirm?.call();
                    Navigator.of(context).pop(true);
                  },
            child: Text(
              confirmLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: !confirmEnabled
                    ? TevioThemeColors.secondaryText(context)
                    : isDestructive
                    ? TevioColors.danger
                    : TevioColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TevioAnimatedStatus extends StatelessWidget {
  const TevioAnimatedStatus({
    super.key,
    required this.child,
    this.animate = true,
  });

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: TevioMotion.normal,
      switchInCurve: TevioMotion.standardCurve,
      switchOutCurve: TevioMotion.standardCurve,
      child: animate
          ? child
          : KeyedSubtree(key: const ValueKey('static'), child: child),
    );
  }
}
