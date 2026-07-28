import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
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
    this.onTap,
  });

  final String name;
  final String brand;
  final String modelNumber;
  final String purchasedAt;
  final String warrantyText;
  final RightsStatus status;
  final String summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TevioCard(
      onTap: onTap,
      padding: const EdgeInsets.all(TevioSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(name, style: textTheme.titleMedium)),
              const SizedBox(width: TevioSpacing.sm),
              TevioStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: TevioSpacing.xxs),
          Text(
            '$brand · $modelNumber',
            style: textTheme.labelLarge?.copyWith(
              color: TevioColors.textSecondary,
            ),
          ),
          const SizedBox(height: TevioSpacing.md),
          Text(
            summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: TevioColors.textPrimary,
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
            color: TevioColors.textTertiary,
          ),
        ),
        const SizedBox(height: TevioSpacing.xxs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(
            color: TevioColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
