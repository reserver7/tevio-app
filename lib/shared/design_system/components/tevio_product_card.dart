import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
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
    this.onTap,
    this.thumbnail,
  });

  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String warrantyText;
  final RightsStatus status;
  final String summary;
  final VoidCallback? onTap;
  final Widget? thumbnail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: onTap != null,
      label: '$name, ${status.label}, $summary',
      child: TevioCard(
        onTap: onTap,
        accentColor: status.foreground,
        padding: const EdgeInsets.all(TevioSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductThumbnail(status: status, child: thumbnail),
                const SizedBox(width: TevioSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: textTheme.titleMedium),
                      const SizedBox(height: TevioSpacing.xxs),
                      Text(
                        '$brand · $modelNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(
                          color: TevioThemeColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TevioSpacing.sm),
                TevioStatusBadge(status: status),
              ],
            ),
            const SizedBox(height: TevioSpacing.md),
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: TevioThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: TevioSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: TevioSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _ProductMeta(label: '구매일', value: purchasedAt),
                ),
                const SizedBox(width: TevioSpacing.md),
                Expanded(
                  child: _ProductMeta(
                    label: '보증',
                    value: warrantyText.replaceFirst('보증 ', ''),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductMeta extends StatelessWidget {
  const _ProductMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: TevioThemeColors.secondaryText(context),
          ),
        ),
        const SizedBox(height: TevioSpacing.xxs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(
            color: TevioThemeColors.secondaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.status, this.child});

  final RightsStatus status;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox.square(
        dimension: 44,
        child: ColoredBox(
          color: status.background,
          child:
              child ??
              Icon(Icons.inventory_2_outlined, color: status.foreground),
        ),
      ),
    );
  }
}
