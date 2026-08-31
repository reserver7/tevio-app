import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
import 'tevio_status_badge.dart';

class TevioProductSummaryCard extends StatelessWidget {
  const TevioProductSummaryCard({
    super.key,
    required this.name,
    required this.identity,
    required this.status,
    required this.summary,
    this.primaryLabel,
    this.onPrimaryPressed,
  });

  final String name;
  final String identity;
  final RightsStatus status;
  final String summary;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onPrimaryPressed != null,
      label: [
        name,
        identity,
        status.label,
        summary,
        primaryLabel,
      ].nonNulls.join(', '),
      child: Material(
        color: TevioColors.transparent,
        child: InkWell(
          onTap: onPrimaryPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TevioSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: TevioSpacing.xxs),
                      Text(
                        identity,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: TevioThemeColors.secondaryText(context),
                            ),
                      ),
                      const SizedBox(height: TevioSpacing.sm),
                      Text(
                        summary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (primaryLabel != null) ...[
                        const SizedBox(height: TevioSpacing.xs),
                        Text(
                          primaryLabel!,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: status.foreground),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: TevioSpacing.md),
                TevioStatusBadge(status: status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TevioTimeline<T> extends StatelessWidget {
  const TevioTimeline({
    super.key,
    required this.items,
    required this.titleBuilder,
    required this.descriptionBuilder,
    required this.timeBuilder,
    this.statusBuilder,
  });

  final List<T> items;
  final String Function(T) titleBuilder;
  final String Function(T) descriptionBuilder;
  final String Function(T) timeBuilder;
  final RightsStatus? Function(T)? statusBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          _TimelineItem(
            title: titleBuilder(items[index]),
            description: descriptionBuilder(items[index]),
            time: timeBuilder(items[index]),
            status: statusBuilder?.call(items[index]),
            isLast: index == items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.description,
    required this.time,
    required this.status,
    required this.isLast,
  });

  final String title;
  final String description;
  final String time;
  final RightsStatus? status;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = status?.foreground ?? TevioColors.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              AnimatedContainer(
                duration: TevioMotion.fast,
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(width: 1, height: 58, color: TevioColors.divider),
            ],
          ),
        ),
        const SizedBox(width: TevioSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: TevioSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(time, style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                const SizedBox(height: TevioSpacing.xxs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
