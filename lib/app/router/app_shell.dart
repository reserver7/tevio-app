import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/presentation/state/product_registration_session.dart';
import '../../features/settings/presentation/state/my_tab_session.dart';
import '../../shared/design_system/tevio_design_system.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: TevioColors.divider)),
        ),
        child: TevioBottomNavigation(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              ref.read(productRegistrationSessionProvider.notifier).reset();
            }
            if (index == 3) {
              ref.read(myTabSessionProvider.notifier).reset();
            }
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
