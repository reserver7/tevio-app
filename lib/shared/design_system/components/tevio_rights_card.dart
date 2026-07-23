import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
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
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TevioStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: TevioSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TevioSpacing.xs),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if (dueText != null) ...[
            const SizedBox(height: TevioSpacing.sm),
            Text(
              dueText!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: TevioColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: TevioSpacing.md),
          Row(
            children: [
              Text(
                actionLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TevioColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: TevioColors.primary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
