import 'package:flutter/material.dart';

import '../models/rights_status.dart';
import 'tevio_operational_patterns.dart';

class TevioRightsCard extends StatelessWidget {
  const TevioRightsCard({
    super.key,
    required this.status,
    required this.productName,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.dueText,
    this.onPressed,
  });

  final RightsStatus status;
  final String productName;
  final String title;
  final String description;
  final String actionLabel;
  final String? dueText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TevioActionCard(
      status: status,
      eyebrow: productName,
      title: title,
      description: description,
      supportingText: dueText ?? status.label,
      actionLabel: actionLabel,
      onPressed: onPressed,
    );
  }
}
