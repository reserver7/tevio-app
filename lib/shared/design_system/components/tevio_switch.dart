import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioSwitch extends StatelessWidget {
  const TevioSwitch({
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
      toggled: value,
      enabled: onChanged != null,
      label: label,
      hint: description,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TevioSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodyLarge),
                    if (description != null) ...[
                      const SizedBox(height: TevioSpacing.xxs),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TevioThemeColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                thumbIcon: WidgetStatePropertyAll(
                  Icon(
                    value ? Icons.check : Icons.circle,
                    size: TevioDimensions.iconSmall,
                  ),
                ),
                activeThumbColor: TevioColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
