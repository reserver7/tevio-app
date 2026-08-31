import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';
import '../tokens/tevio_spacing.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioSheet extends StatelessWidget {
  const TevioSheet({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.footer,
  });

  final String title;
  final Widget child;
  final Widget? action;
  final Widget? footer;

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool useRootNavigator = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      // TevioSheet renders the branded handle itself.
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: TevioColors.scrim,
      clipBehavior: Clip.antiAlias,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TevioSpacing.lg,
            TevioSpacing.sm,
            TevioSpacing.lg,
            TevioSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TevioThemeColors.secondaryText(context),
                    borderRadius: TevioRadius.fullBorder,
                  ),
                ),
              ),
              const SizedBox(height: TevioSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ?action,
                ],
              ),
              const SizedBox(height: TevioSpacing.lg),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  primary: false,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: child,
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: TevioSpacing.md),
                Divider(height: 1, color: TevioThemeColors.divider(context)),
                const SizedBox(height: TevioSpacing.md),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TevioSnackbar {
  const TevioSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}
