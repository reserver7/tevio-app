import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
import 'tevio_card.dart';
import 'tevio_status_badge.dart';

/// A single, actionable piece of operational information.
///
/// This is for a decision a customer can make now, not for decorative cards.
/// The entire surface is tappable and its footer describes the resulting action.
class TevioActionCard extends StatelessWidget {
  const TevioActionCard({
    super.key,
    required this.title,
    required this.description,
    this.status,
    this.eyebrow,
    this.supportingText,
    this.actionLabel,
    this.onPressed,
    this.compact = false,
  });

  final RightsStatus? status;
  final String title;
  final String description;
  final String? eyebrow;
  final String? supportingText;
  final String? actionLabel;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final canOpen = onPressed != null;
    final label = [
      eyebrow,
      title,
      status?.label,
      description,
      actionLabel,
    ].join(', ');

    return Semantics(
      button: canOpen,
      enabled: canOpen,
      label: label,
      child: TevioCard(
        onTap: onPressed,
        accentColor: status?.foreground,
        padding: EdgeInsets.all(compact ? TevioSpacing.md : TevioSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null || status != null) ...[
              Row(
                children: [
                  Expanded(
                    child: eyebrow == null
                        ? const SizedBox.shrink()
                        : Text(
                            eyebrow!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: TevioThemeColors.secondaryText(
                                    context,
                                  ),
                                ),
                          ),
                  ),
                  if (status != null) TevioStatusBadge(status: status!),
                ],
              ),
              SizedBox(height: compact ? TevioSpacing.sm : TevioSpacing.md),
            ],
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TevioSpacing.xs),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            if (supportingText != null) ...[
              const SizedBox(height: TevioSpacing.sm),
              Text(
                supportingText!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: TevioThemeColors.secondaryText(context),
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: TevioSpacing.md),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: TevioColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A standard navigation or preference row.
///
/// The chevron is shown only when the row is interactive so static information
/// is never mistaken for a route.
class TevioListRow extends StatelessWidget {
  const TevioListRow({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.value,
    this.onTap,
    this.isDestructive = false,
    this.showChevron,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? value;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final interactive = onTap != null;
    final shouldShowChevron = showChevron ?? interactive;
    final foreground = isDestructive
        ? TevioColors.danger
        : TevioThemeColors.primaryText(context);
    final iconColor = isDestructive ? TevioColors.danger : TevioColors.primary;

    return Semantics(
      button: interactive,
      enabled: interactive,
      label: [title, value, description].nonNulls.join(', '),
      child: Material(
        color: TevioColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: TevioRadius.mediumBorder,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TevioDimensions.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TevioSpacing.xs,
                vertical: TevioSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: TevioDimensions.minTouchTarget,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(icon, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: TevioSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: foreground),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: TevioSpacing.xxs),
                          Text(
                            description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(
                    width: value == null ? 0 : 112,
                    child: value == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.only(
                              left: TevioSpacing.sm,
                            ),
                            child: Text(
                              value!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                  ),
                  SizedBox(
                    width: shouldShowChevron
                        ? TevioDimensions.minTouchTarget
                        : 0,
                    height: TevioDimensions.minTouchTarget,
                    child: shouldShowChevron
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.chevron_right,
                              color: TevioThemeColors.secondaryText(context),
                            ),
                          )
                        : null,
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

/// Small text command for secondary actions such as reset or mark-all-read.
class TevioTextAction extends StatelessWidget {
  const TevioTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = !enabled
        ? TevioThemeColors.secondaryText(context)
        : isDestructive
        ? TevioColors.danger
        : TevioColors.primary;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: TevioColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: TevioRadius.smallBorder,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TevioDimensions.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TevioSpacing.sm),
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
