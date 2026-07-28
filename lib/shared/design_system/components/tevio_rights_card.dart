import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import 'tevio_card.dart';
import 'tevio_status_badge.dart';

class TevioRightsCard extends StatelessWidget {
  const TevioRightsCard({
    super.key,
    required this.status,
    required this.productName,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.dueText,
    this.onPressed,
  });

  final RightsStatus status;
  final String productName;
  final String title;
  final String description;
  final String actionLabel;
  final String? dueText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TevioCard(
      onTap: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  productName,
                  style: textTheme.labelLarge?.copyWith(
                    color: TevioColors.textSecondary,
                  ),
                ),
              ),
              TevioStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: TevioSpacing.sm),
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: TevioSpacing.xs),
          Text(description, style: textTheme.bodyMedium),
          const SizedBox(height: TevioSpacing.md),
          Row(
            children: [
              _RightsDuePill(status: status, label: dueText ?? status.label),
              const Spacer(),
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
            ],
          ),
        ],
      ),
    );
  }
}

class _RightsDuePill extends StatelessWidget {
  const _RightsDuePill({required this.status, required this.label});

  final RightsStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: TevioRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TevioSpacing.sm,
          vertical: TevioSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: status.foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
