import 'package:flutter/material.dart';

import 'tevio_operational_patterns.dart';

class TevioSectionHeader extends StatelessWidget {
  const TevioSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null)
          TevioTextAction(label: actionLabel!, onPressed: onActionPressed),
      ],
    );
  }
}
