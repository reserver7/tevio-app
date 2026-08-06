import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';

class TevioStatusBadge extends StatelessWidget {
  const TevioStatusBadge({super.key, required this.status, this.label});

  final RightsStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label ?? status.label;

    return Semantics(
      label: '상태 $text',
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: status.background,
          borderRadius: TevioRadius.fullBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusMark(status: status),
              const SizedBox(width: 6),
              Text(
                text,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: status.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.status});

  final RightsStatus status;

  @override
  Widget build(BuildContext context) {
    if (status != RightsStatus.processing) {
      return SizedBox.square(
        dimension: TevioDimensions.statusDot,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: status.foreground,
            borderRadius: TevioRadius.fullBorder,
          ),
        ),
      );
    }

    return AnimatedRotation(
      turns: 1,
      duration: TevioMotion.normal,
      child: Icon(
        Icons.sync,
        size: TevioDimensions.statusDot + 4,
        color: status.foreground,
      ),
    );
  }
}
