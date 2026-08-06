import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';
import 'tevio_button.dart';
import 'tevio_card.dart';
import 'tevio_icon_button.dart';
import 'tevio_sheet.dart';

/// A themed date input that keeps platform picker details out of feature UI.
class TevioDateField extends StatelessWidget {
  const TevioDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.helpText,
    this.errorText,
    this.enabled = true,
    this.allowClear = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? helpText;
  final String? errorText;
  final bool enabled;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final dateText = value == null
        ? '날짜 선택'
        : '${value!.year}. ${value!.month.toString().padLeft(2, '0')}. ${value!.day.toString().padLeft(2, '0')}.';
    final borderColor = errorText == null
        ? TevioThemeColors.border(context)
        : TevioColors.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: TevioSpacing.xs),
        Semantics(
          button: true,
          enabled: enabled,
          label: '$label, $dateText',
          child: Material(
            color: TevioColors.transparent,
            child: InkWell(
              borderRadius: TevioRadius.mediumBorder,
              onTap: !enabled
                  ? null
                  : () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: value ?? DateTime.now(),
                        firstDate: firstDate,
                        lastDate: lastDate,
                        helpText: helpText ?? label,
                      );
                      if (selected != null) onChanged(selected);
                    },
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: TevioDimensions.inputHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: TevioSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? TevioThemeColors.surface(context)
                      : TevioThemeColors.selectedSurface(context),
                  borderRadius: TevioRadius.mediumBorder,
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20),
                    const SizedBox(width: TevioSpacing.sm),
                    Expanded(
                      child: Text(
                        dateText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (allowClear && value != null) ...[
                      TevioIconButton(
                        icon: Icons.close,
                        tooltip: '선택한 날짜 지우기',
                        onPressed: () => onChanged(null),
                      ),
                      const SizedBox(width: TevioSpacing.xs),
                    ],
                    Icon(
                      Icons.chevron_right,
                      color: TevioThemeColors.secondaryText(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: TevioSpacing.xs),
          Text(
            errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TevioColors.danger),
          ),
        ],
      ],
    );
  }
}

/// Standard cached remote image with themed loading and failure states.
class TevioNetworkImage extends StatelessWidget {
  const TevioNetworkImage({
    super.key,
    required this.imageUrl,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = TevioRadius.mediumBorder,
    this.placeholder,
    this.errorBuilder,
  });

  final String? imageUrl;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final WidgetBuilder? placeholder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final defaultPlaceholder = ColoredBox(
      color: TevioThemeColors.selectedSurface(context),
      child: const Center(child: Icon(Icons.image_outlined)),
    );
    final placeholder = this.placeholder?.call(context) ?? defaultPlaceholder;
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Semantics(label: semanticLabel, child: _frame(placeholder));
    }
    return Semantics(
      image: true,
      label: semanticLabel,
      child: _frame(
        CachedNetworkImage(
          imageUrl: imageUrl!,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => placeholder,
          errorWidget: (context, url, error) =>
              errorBuilder?.call(context, error) ??
              ColoredBox(
                color: TevioThemeColors.selectedSurface(context),
                child: const Center(child: Icon(Icons.broken_image_outlined)),
              ),
        ),
      ),
    );
  }

  Widget _frame(Widget child) => ClipRRect(
    borderRadius: borderRadius,
    child: SizedBox(width: width, height: height, child: child),
  );
}

/// Generic document surface. Features supply file metadata and their action.
class TevioDocumentPreview extends StatelessWidget {
  const TevioDocumentPreview({
    super.key,
    required this.title,
    required this.description,
    required this.onOpen,
    this.actionLabel = '문서 열기',
    this.isLoading = false,
    this.enabled = true,
    this.errorText,
    this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback onOpen;
  final String actionLabel;
  final bool isLoading;
  final bool enabled;
  final String? errorText;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: TevioColors.primary),
          const SizedBox(width: TevioSpacing.md),
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
                if (errorText != null) ...[
                  const SizedBox(height: TevioSpacing.xxs),
                  Text(
                    errorText!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: TevioColors.danger),
                  ),
                ],
              ],
            ),
          ),
          TevioIconButton(
            tooltip: actionLabel,
            onPressed: !enabled || isLoading
                ? null
                : errorText == null
                ? onOpen
                : onRetry,
            icon: isLoading
                ? Icons.hourglass_top_outlined
                : errorText == null
                ? Icons.open_in_new
                : Icons.refresh,
          ),
        ],
      ),
    );
  }
}

/// Reusable permission explanation. Features decide when to request permission.
class TevioPermissionRequest extends StatelessWidget {
  const TevioPermissionRequest({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onRequest,
    this.actionLabel = '허용하기',
    this.isLoading = false,
    this.enabled = true,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onRequest;
  final String actionLabel;
  final bool isLoading;
  final bool enabled;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return TevioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TevioColors.primary),
          const SizedBox(height: TevioSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TevioSpacing.xs),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: TevioSpacing.lg),
          TevioLoadingButton(
            label: actionLabel,
            isLoading: isLoading,
            onPressed: enabled ? onRequest : null,
          ),
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: TevioSpacing.sm),
            TevioButton(
              label: secondaryActionLabel!,
              variant: TevioButtonVariant.secondary,
              onPressed: enabled && !isLoading ? onSecondaryAction : null,
            ),
          ],
        ],
      ),
    );
  }
}

class TevioConfirmSheet extends StatelessWidget {
  const TevioConfirmSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.isDestructive = false,
    this.cancelLabel = '취소',
    this.isConfirmLoading = false,
    this.confirmEnabled = true,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final bool isDestructive;
  final String cancelLabel;
  final bool isConfirmLoading;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    return TevioSheet(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: TevioSpacing.xl),
          TevioLoadingButton(
            label: confirmLabel,
            variant: isDestructive
                ? TevioButtonVariant.danger
                : TevioButtonVariant.primary,
            isLoading: isConfirmLoading,
            onPressed: confirmEnabled
                ? () => Navigator.of(context).pop(true)
                : null,
          ),
          const SizedBox(height: TevioSpacing.sm),
          TevioButton(
            label: cancelLabel,
            variant: TevioButtonVariant.secondary,
            onPressed: isConfirmLoading
                ? null
                : () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
