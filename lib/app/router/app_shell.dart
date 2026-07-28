import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/presentation/state/product_registration_session.dart';
import '../../features/settings/presentation/state/my_tab_session.dart';
import '../../shared/design_system/tevio_design_system.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabLocations = ['/home', '/products', '/register', '/settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndexFor(location);
    final showBottomNavigation = _tabLocations.contains(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNavigation
          ? DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: TevioColors.divider)),
              ),
              child: TevioBottomNavigation(
                currentIndex: currentIndex,
                onDestinationSelected: (index) {
                  if (index == 2) {
                    ref
                        .read(productRegistrationSessionProvider.notifier)
                        .reset();
                  }
                  if (index == 3) {
                    ref.read(myTabSessionProvider.notifier).reset();
                  }
                  context.go(_tabLocations[index]);
                },
              ),
            )
          : null,
    );
  }

  int _currentIndexFor(String location) {
    if (location.startsWith('/products')) {
      return 1;
    }
    if (location.startsWith('/register')) {
      return 2;
    }
    if (location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }
}
