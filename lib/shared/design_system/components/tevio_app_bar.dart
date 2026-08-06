import 'package:flutter/material.dart';

import '../tokens/tevio_spacing.dart';

class TevioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TevioAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final String? subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      titleSpacing: TevioSpacing.lg,
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
        ],
      ),
      actions: actions == null
          ? null
          : [
              const SizedBox(width: TevioSpacing.xs),
              ...actions!,
              const SizedBox(width: TevioSpacing.xs),
            ],
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
}
