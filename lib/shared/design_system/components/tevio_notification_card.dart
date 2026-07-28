import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_spacing.dart';
import 'tevio_card.dart';

class TevioNotificationCard extends StatelessWidget {
  const TevioNotificationCard({
    super.key,
    required this.status,
    required this.productName,
    required this.typeLabel,
    required this.title,
    required this.description,
    required this.receivedAt,
    this.isRead = false,
    this.onTap,
  });

  final RightsStatus status;
  final String productName;
  final String typeLabel;
  final String title;
  final String description;
  final String receivedAt;
  final bool isRead;
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
            children: [
              if (!isRead) ...[
                const _UnreadDot(),
                const SizedBox(width: TevioSpacing.xs),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: isRead
                        ? TevioColors.textSecondary
                        : TevioColors.textPrimary,
                  ),
                ),
              ),
              Text(
                receivedAt,
                style: textTheme.labelMedium?.copyWith(
                  color: TevioColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: TevioSpacing.xs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: typeLabel,
                  style: textTheme.labelLarge?.copyWith(
                    color: status.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(text: ' · $productName'),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              color: TevioColors.textSecondary,
            ),
          ),
          const SizedBox(height: TevioSpacing.xxs),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: isRead
                  ? TevioColors.textTertiary
                  : TevioColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: TevioSpacing.xs,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TevioColors.mint,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
