import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import 'tevio_card.dart';
import 'tevio_status_badge.dart';

class TevioProductCard extends StatelessWidget {
  const TevioProductCard({
    super.key,
    required this.name,
    required this.brand,
    required this.modelNumber,
    required this.purchasedAt,
    required this.warrantyText,
    required this.status,
    required this.summary,
    required this.actionLabel,
    this.onTap,
  });

  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String warrantyText;
  final RightsStatus status;
  final String summary;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TevioCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductIcon(status: status),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(name, style: textTheme.titleMedium)),
                    const SizedBox(width: TevioSpacing.xs),
                    TevioStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: TevioSpacing.xs),
                Text(
                  '$brand · $modelNumber',
                  style: textTheme.labelLarge?.copyWith(
                    color: TevioColors.textSecondary,
                  ),
                ),
                const SizedBox(height: TevioSpacing.sm),
                Text(summary, style: textTheme.bodyMedium),
                const SizedBox(height: TevioSpacing.md),
                Row(
                  children: [
                    _ProductDuePill(label: warrantyText),
                    const Spacer(),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              actionLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge?.copyWith(
                                color: TevioColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: TevioSpacing.xxs),
                          const Icon(
                            Icons.chevron_right,
                            color: TevioColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TevioSpacing.xs),
                Text(
                  '구매일 $purchasedAt',
                  style: textTheme.labelMedium?.copyWith(
                    color: TevioColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDuePill extends StatelessWidget {
  const _ProductDuePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final displayLabel = label.startsWith('보증') ? label : '보증 $label';

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TevioColors.primaryBackground,
        borderRadius: TevioRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TevioSpacing.sm,
          vertical: TevioSpacing.xs,
        ),
        child: Text(
          displayLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: TevioColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ProductIcon extends StatelessWidget {
  const _ProductIcon({required this.status});

  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: TevioRadius.mediumBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.md),
        child: Icon(status.icon, color: status.foreground),
      ),
    );
  }
}
