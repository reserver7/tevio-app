import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
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
    required this.actionLabel,
    this.isRead = false,
    this.onTap,
  });

  final RightsStatus status;
  final String productName;
  final String typeLabel;
  final String title;
  final String description;
  final String receivedAt;
  final String actionLabel;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TevioCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NotificationIcon(status: status),
              const SizedBox(width: TevioSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
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
          Text(
            '$typeLabel · $productName',
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
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: TevioSpacing.sm),
          Row(
            children: [
              if (!isRead) ...[
                const _UnreadDot(),
                const SizedBox(width: TevioSpacing.xs),
              ],
              Expanded(
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
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.status});

  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: TevioRadius.smallBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.xs),
        child: Icon(status.icon, color: status.foreground, size: 16),
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
