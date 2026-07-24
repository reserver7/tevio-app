import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_spacing.dart';
import 'tevio_button.dart';
import 'tevio_logo.dart';

class TevioLoadingState extends StatelessWidget {
  const TevioLoadingState({super.key, this.label = '불러오는 중이에요'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: TevioSpacing.md),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TevioLogo(variant: TevioLogoVariant.symbol, size: 56),
            const SizedBox(height: TevioSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TevioSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: TevioSpacing.lg),
              TevioButton(label: actionLabel!, onPressed: onActionPressed),
            ],
          ],
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: TevioColors.danger,
              size: 40,
            ),
            const SizedBox(height: TevioSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TevioSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetryPressed != null) ...[
              const SizedBox(height: TevioSpacing.lg),
              TevioButton(label: actionLabel, onPressed: onRetryPressed),
            ],
          ],
        ),
      ),
    );
  }
}
