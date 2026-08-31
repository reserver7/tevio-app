import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

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
    return Semantics(
      button: onTap != null,
      label:
          '$typeLabel, $productName, $title, $description, $receivedAt${isRead ? ', 읽음' : ', 읽지 않음'}',
      child: AnimatedOpacity(
        duration: TevioMotion.fast,
        opacity: isRead ? .68 : 1,
        child: Material(
          color: TevioColors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TevioSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 18,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: TevioMotion.fast,
                          width: isRead ? 8 : 10,
                          height: isRead ? 8 : 10,
                          decoration: BoxDecoration(
                            color: isRead
                                ? TevioThemeColors.divider(context)
                                : status.foreground,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: TevioSpacing.xxs),
                        Container(
                          width: 2,
                          height: 60,
                          color: TevioThemeColors.divider(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TevioSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  color: isRead
                                      ? TevioThemeColors.secondaryText(context)
                                      : TevioThemeColors.primaryText(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: TevioSpacing.sm),
                            Text(
                              receivedAt,
                              style: textTheme.labelMedium?.copyWith(
                                color: TevioThemeColors.secondaryText(context),
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
                            color: status.foreground,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: TevioSpacing.xxs),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: TevioThemeColors.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
