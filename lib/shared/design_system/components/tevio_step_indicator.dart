import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';

class TevioStepIndicator extends StatelessWidget {
  const TevioStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < totalSteps; index++) ...[
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: index <= currentStep
                    ? TevioColors.primary
                    : TevioColors.divider,
                borderRadius: TevioRadius.fullBorder,
              ),
              child: const SizedBox(height: TevioSpacing.xxs),
            ),
          ),
          if (index < totalSteps - 1) const SizedBox(width: TevioSpacing.xs),
        ],
      ],
    );
  }
}
