import 'package:flutter/material.dart';

import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
import 'tevio_button.dart';

/// Shared page frame for consistent safe-area and scroll insets.
class TevioPageScrollView extends StatelessWidget {
  const TevioPageScrollView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      TevioSpacing.lg,
      TevioSpacing.sm,
      TevioSpacing.lg,
      TevioSpacing.xl,
    ),
    this.storageKey,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final String? storageKey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        key: storageKey == null ? null : PageStorageKey<String>(storageKey!),
        padding: padding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: children,
      ),
    );
  }
}

class TevioTaskActionBar extends StatelessWidget {
  const TevioTaskActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.primaryIcon,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final IconData? primaryIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Material(
      color: TevioThemeColors.surface(context),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          TevioSpacing.lg,
          TevioSpacing.sm,
          TevioSpacing.lg,
          TevioSpacing.md,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackActions = constraints.maxWidth < 340 || textScale > 1.25;
            final primary = TevioButton(
              label: primaryLabel,
              icon: primaryIcon,
              onPressed: onPrimaryPressed,
            );
            if (secondaryLabel == null) return primary;
            final secondary = TevioButton(
              label: secondaryLabel!,
              variant: TevioButtonVariant.secondary,
              onPressed: onSecondaryPressed,
            );
            if (stackActions) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  secondary,
                  const SizedBox(height: TevioSpacing.sm),
                  primary,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: secondary),
                const SizedBox(width: TevioSpacing.sm),
                Expanded(child: primary),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TevioPageIntro extends StatelessWidget {
  const TevioPageIntro({
    super.key,
    required this.title,
    required this.description,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String description;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: eyebrow == null ? 54 : 76,
            margin: const EdgeInsets.only(top: TevioSpacing.xxs),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF20BFA9),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: TevioSpacing.xs),
                      Expanded(
                        child: Text(
                          eyebrow!,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TevioSpacing.xs),
                ],
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: TevioSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TevioThemeColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: TevioSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class TevioMetric {
  const TevioMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class TevioMetricStrip extends StatelessWidget {
  const TevioMetricStrip({super.key, required this.metrics});

  final List<TevioMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: metrics.map((item) => '${item.label} ${item.value}').join(', '),
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            if (index > 0)
              SizedBox(
                height: 32,
                child: VerticalDivider(
                  color: TevioThemeColors.divider(context),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metrics[index].value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: TevioSpacing.xxs),
                  Text(
                    metrics[index].label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: TevioThemeColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TevioListSection extends StatelessWidget {
  const TevioListSection({
    super.key,
    required this.children,
    this.title,
    this.description,
  });

  final String? title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          if (description != null) ...[
            const SizedBox(height: TevioSpacing.xxs),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TevioThemeColors.secondaryText(context),
              ),
            ),
          ],
          const SizedBox(height: TevioSpacing.sm),
        ],
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1)
            Divider(color: TevioThemeColors.divider(context), height: 1),
        ],
      ],
    );
  }
}
