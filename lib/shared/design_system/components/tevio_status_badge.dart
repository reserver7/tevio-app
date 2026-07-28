import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import '../tokens/tevio_radius.dart';

class TevioStatusBadge extends StatelessWidget {
  const TevioStatusBadge({super.key, required this.status, this.label});

  final RightsStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: TevioRadius.fullBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label ?? status.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: status.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
