import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';

class TevioCompletionView extends StatelessWidget {
  const TevioCompletionView({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            color: TevioColors.successBackground,
            borderRadius: TevioRadius.fullBorder,
          ),
          child: Padding(
            padding: EdgeInsets.all(TevioSpacing.lg),
            child: Icon(Icons.check, color: TevioColors.mint, size: 44),
          ),
        ),
        const SizedBox(height: TevioSpacing.lg),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: TevioSpacing.xs),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
