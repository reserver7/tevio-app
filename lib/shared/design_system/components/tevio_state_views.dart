import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
import 'tevio_button.dart';

class TevioLoadingState extends StatelessWidget {
  const TevioLoadingState({super.key, this.label = '불러오는 중이에요'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TevioSpacing.xl),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
            ),
            const SizedBox(width: TevioSpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

class TevioEmptyState extends StatelessWidget {
  const TevioEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title. $description',
      child: _StateFrame(
        color: TevioColors.mint,
        title: title,
        description: description,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      ),
    );
  }
}

class TevioErrorState extends StatelessWidget {
  const TevioErrorState({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel = '다시 시도',
    this.onRetryPressed,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: '$title. $description',
      child: _StateFrame(
        color: TevioColors.danger,
        title: title,
        description: description,
        actionLabel: onRetryPressed == null ? null : actionLabel,
        onActionPressed: onRetryPressed,
      ),
    );
  }
}

class _StateFrame extends StatelessWidget {
  const _StateFrame({
    required this.color,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  final Color color;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TevioSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TevioSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TevioThemeColors.secondaryText(context),
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: TevioSpacing.lg),
                  TevioButton(
                    label: actionLabel!,
                    onPressed: onActionPressed,
                    isExpanded: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
