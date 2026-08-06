import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_motion.dart';
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
    final completedSteps = (currentStep + 1).clamp(0, totalSteps);
    return Semantics(
      label: '전체 $totalSteps단계 중 $completedSteps단계',
      value: '${((completedSteps / totalSteps) * 100).round()}%',
      child: Row(
        children: [
          for (var index = 0; index < totalSteps; index++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: TevioMotion.fast,
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
      ),
    );
  }
}
