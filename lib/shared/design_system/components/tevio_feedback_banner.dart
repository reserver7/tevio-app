import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import 'tevio_operational_patterns.dart';

class TevioFeedbackBanner extends StatelessWidget {
  const TevioFeedbackBanner({
    super.key,
    required this.status,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  final RightsStatus status;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: '$title. $description',
      child: Container(
        padding: const EdgeInsets.all(TevioSpacing.md),
        decoration: BoxDecoration(
          color: status.background,
          borderRadius: TevioRadius.largeBorder,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(status.icon, color: status.foreground),
            const SizedBox(width: TevioSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: TevioSpacing.xxs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(height: TevioSpacing.xs),
                    TevioTextAction(
                      label: actionLabel!,
                      onPressed: onActionPressed,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
