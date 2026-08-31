import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
import 'tevio_button.dart';
import 'tevio_status_badge.dart';

class TevioProductIdentity extends StatelessWidget {
  const TevioProductIdentity({
    super.key,
    required this.name,
    required this.brand,
    required this.modelNumber,
    required this.status,
  });

  final String name;
  final String brand;
  final String modelNumber;
  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '$name, $brand, 모델번호 $modelNumber, ${status.label}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TevioThemeColors.selectedSurface(context),
              borderRadius: TevioRadius.mediumBorder,
            ),
            child: Text(
              name.trim().isEmpty ? '?' : name.trim().characters.first,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TevioColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: TevioSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: TevioSpacing.xxs),
                Text(
                  '$brand · $modelNumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TevioThemeColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: TevioSpacing.sm),
          TevioStatusBadge(status: status),
        ],
      ),
    );
  }
}

class TevioDecisionPanel extends StatelessWidget {
  const TevioDecisionPanel({
    super.key,
    required this.status,
    required this.title,
    required this.reason,
    required this.actionLabel,
    required this.onPressed,
    this.deadline,
    this.contextLabel,
  });

  final RightsStatus status;
  final String title;
  final String reason;
  final String? deadline;
  final String? contextLabel;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: [
        contextLabel,
        status.label,
        title,
        reason,
        deadline,
        actionLabel,
      ].nonNulls.join(', '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: status.background,
          borderRadius: TevioRadius.largeBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TevioSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: status.foreground,
                      borderRadius: TevioRadius.fullBorder,
                    ),
                  ),
                  const SizedBox(width: TevioSpacing.sm),
                  Expanded(
                    child: Text(
                      contextLabel ?? status.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: status.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (deadline != null) ...[
                const SizedBox(height: TevioSpacing.xs),
                Text(
                  deadline!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: status.foreground),
                ),
              ],
              const SizedBox(height: TevioSpacing.md),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: TevioSpacing.xs),
              Text(reason, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: TevioSpacing.lg),
              TevioButton(label: actionLabel, onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}

class TevioRightRailItem {
  const TevioRightRailItem({
    required this.label,
    required this.value,
    required this.description,
    required this.status,
    this.onTap,
  });

  final String label;
  final String value;
  final String description;
  final RightsStatus status;
  final VoidCallback? onTap;
}

class TevioRightsRail extends StatelessWidget {
  const TevioRightsRail({super.key, required this.items});

  final List<TevioRightRailItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          _RightsRailRow(item: items[index], isLast: index == items.length - 1),
      ],
    );
  }
}

class _RightsRailRow extends StatelessWidget {
  const _RightsRailRow({required this.item, required this.isLast});

  final TevioRightRailItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: item.onTap != null,
      label: '${item.label}, ${item.value}, ${item.description}',
      child: InkWell(
        onTap: item.onTap,
        borderRadius: TevioRadius.mediumBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TevioSpacing.sm),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.status.foreground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.only(
                              top: TevioSpacing.xxs,
                            ),
                            color: TevioThemeColors.divider(context),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: TevioSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: TevioSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.label,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(width: TevioSpacing.sm),
                            Text(
                              item.value,
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: item.status.foreground,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TevioSpacing.xxs),
                        Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TevioEvidenceItem {
  const TevioEvidenceItem({
    required this.label,
    required this.value,
    this.isReady = true,
  });

  final String label;
  final String value;
  final bool isReady;
}

class TevioProcessStep {
  const TevioProcessStep({required this.label, this.description});

  final String label;
  final String? description;
}

class TevioProcessTracker extends StatelessWidget {
  const TevioProcessTracker({
    super.key,
    required this.steps,
    required this.currentStep,
    this.updatedAt,
  });

  final List<TevioProcessStep> steps;
  final int currentStep;
  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    assert(steps.isNotEmpty, 'TevioProcessTracker requires at least one step.');
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeCurrentStep = currentStep.clamp(0, steps.length - 1) as int;
    return Semantics(
      container: true,
      label:
          '처리 단계 ${safeCurrentStep + 1}/${steps.length}, ${steps[safeCurrentStep].label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var index = 0; index < steps.length; index++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= safeCurrentStep
                          ? TevioColors.primary
                          : TevioThemeColors.divider(context),
                      borderRadius: TevioRadius.fullBorder,
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  const SizedBox(width: TevioSpacing.xxs),
              ],
            ],
          ),
          const SizedBox(height: TevioSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[safeCurrentStep].label,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (steps[safeCurrentStep].description != null) ...[
                      const SizedBox(height: TevioSpacing.xxs),
                      Text(
                        steps[safeCurrentStep].description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (updatedAt != null) ...[
                const SizedBox(width: TevioSpacing.sm),
                Text(
                  updatedAt!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class TevioEvidenceVault extends StatelessWidget {
  const TevioEvidenceVault({super.key, required this.items, this.onManage});

  final List<TevioEvidenceItem> items;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: TevioThemeColors.divider(context)),
        borderRadius: TevioRadius.mediumBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TevioSpacing.md),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Row(
                children: [
                  Icon(
                    items[index].isReady
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    size: 20,
                    color: items[index].isReady
                        ? TevioColors.mint
                        : TevioThemeColors.secondaryText(context),
                  ),
                  const SizedBox(width: TevioSpacing.sm),
                  Expanded(child: Text(items[index].label)),
                  const SizedBox(width: TevioSpacing.sm),
                  Flexible(
                    child: Text(
                      items[index].value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              if (index < items.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: TevioSpacing.sm),
                  child: Divider(height: 1),
                ),
            ],
            if (onManage != null) ...[
              const SizedBox(height: TevioSpacing.md),
              TevioButton(
                label: '제품 정보 관리',
                onPressed: onManage,
                variant: TevioButtonVariant.secondary,
                size: TevioButtonSize.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
