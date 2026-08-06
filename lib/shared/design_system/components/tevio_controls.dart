// Radio's legacy callback API is still required for the current Flutter SDK.
// Keep the compatibility warning local to this adapter.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioSearchField extends StatelessWidget {
  const TevioSearchField({
    super.key,
    required this.controller,
    this.hintText = '제품을 검색해 보세요',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => Semantics(
        textField: true,
        enabled: enabled,
        label: '검색',
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: '검색어 지우기',
                    onPressed: !enabled
                        ? null
                        : () {
                            controller.clear();
                            onChanged?.call('');
                          },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
      ),
    );
  }
}

class TevioSelectField<T> extends StatelessWidget {
  const TevioSelectField({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled && onChanged != null,
      label: label ?? hintText ?? '선택',
      child: DropdownButtonFormField<T>(
        initialValue: value,
        hint: hintText == null ? null : Text(hintText!),
        items: [
          for (final item in items)
            DropdownMenuItem<T>(value: item, child: Text(labelBuilder(item))),
        ],
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          errorText: errorText,
          constraints: const BoxConstraints(
            minHeight: TevioDimensions.inputHeight,
          ),
        ),
      ),
    );
  }
}

class TevioCheckControl extends StatelessWidget {
  const TevioCheckControl({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.description,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      label: label,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TevioSpacing.xs),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged == null
                    ? null
                    : (next) => onChanged!(next ?? false),
              ),
              const SizedBox(width: TevioSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodyLarge),
                    if (description != null)
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}

class TevioRadioControl<T> extends StatelessWidget {
  const TevioRadioControl({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.description,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      enabled: onChanged != null,
      label: label,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(value),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: (next) {
                if (next != null) onChanged?.call(next);
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyLarge),
                  if (description != null)
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TevioThemeColors.secondaryText(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TevioProgress extends StatelessWidget {
  const TevioProgress({
    super.key,
    required this.value,
    this.label,
    this.showValue = false,
  });

  final double? value;
  final String? label;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final valueLabel = value == null ? '진행 중' : '${(value! * 100).round()}%';
    return Semantics(
      label: label ?? '진행 상태',
      value: valueLabel,
      liveRegion: value == null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null || showValue)
            Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                if (showValue)
                  Text(
                    valueLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: TevioThemeColors.secondaryText(context),
                    ),
                  ),
              ],
            ),
          if (label != null || showValue)
            const SizedBox(height: TevioSpacing.xs),
          ClipRRect(
            borderRadius: TevioRadius.fullBorder,
            child: LinearProgressIndicator(value: value, minHeight: 6),
          ),
        ],
      ),
    );
  }
}

class TevioSkeleton extends StatefulWidget {
  const TevioSkeleton({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.radius = TevioRadius.medium,
    this.animate = true,
  });

  final double height;
  final double width;
  final Radius radius;
  final bool animate;

  @override
  State<TevioSkeleton> createState() => _TevioSkeletonState();
}

class _TevioSkeletonState extends State<TevioSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: TevioMotion.pulse);
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: TevioThemeColors.divider(context),
          borderRadius: BorderRadius.all(widget.radius),
        ),
      ),
    );
    if (!widget.animate || !TickerMode.of(context)) return child;
    return FadeTransition(
      opacity: Tween<double>(begin: .45, end: .9).animate(_controller),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: TevioThemeColors.divider(context),
            borderRadius: BorderRadius.all(widget.radius),
          ),
        ),
      ),
    );
  }
}

class TevioDivider extends StatelessWidget {
  const TevioDivider({super.key, this.inset = 0});

  final double inset;

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: inset,
    endIndent: inset,
    color: TevioThemeColors.divider(context),
  );
}

class TevioListItem extends StatelessWidget {
  const TevioListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$title${subtitle == null ? '' : ', $subtitle'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: TevioRadius.mediumBorder,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: TevioDimensions.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TevioSpacing.sm),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: TevioSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.bodyLarge),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: TevioSpacing.sm),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: TevioSpacing.sm),
                  Icon(
                    Icons.chevron_right,
                    color: TevioThemeColors.secondaryText(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
