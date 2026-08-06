import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import 'tevio_card.dart';
import 'tevio_status_badge.dart';

class TevioCompletionView extends StatelessWidget {
  const TevioCompletionView({
    super.key,
    required this.title,
    required this.description,
    this.status,
    this.statusLabel,
    this.statusDescription,
  });

  final String title;
  final String description;
  final RightsStatus? status;
  final String? statusLabel;
  final String? statusDescription;

  @override
  Widget build(BuildContext context) {
    final visualStatus = status ?? RightsStatus.completed;
    final isProcessing =
        visualStatus == RightsStatus.processing ||
        visualStatus == RightsStatus.detected;
    return Semantics(
      liveRegion: true,
      label: '$title. $description',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: TevioMotion.normal,
        curve: TevioMotion.standardCurve,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: visualStatus.background,
                borderRadius: TevioRadius.fullBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.all(TevioSpacing.lg),
                child: Icon(
                  isProcessing ? visualStatus.icon : Icons.check,
                  color: visualStatus.foreground,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: TevioSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: TevioSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (status != null) ...[
              const SizedBox(height: TevioSpacing.xl),
              TevioCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '권리 상태',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: TevioSpacing.xs),
                          Text(
                            statusDescription ?? '제품 정보를 확인하고 있어요.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    TevioStatusBadge(
                      status: status!,
                      label: statusLabel ?? '확인 중',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
