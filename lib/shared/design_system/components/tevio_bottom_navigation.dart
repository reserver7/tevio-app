import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_dimensions.dart';
import '../tokens/tevio_motion.dart';
import '../tokens/tevio_theme_colors.dart';

class TevioBottomNavigation extends StatelessWidget {
  const TevioBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    _NavigationItem(Icons.home_outlined, Icons.home, '홈'),
    _NavigationItem(Icons.inventory_2_outlined, Icons.inventory_2, '제품'),
    _NavigationItem(Icons.person_outline, Icons.person, '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TevioThemeColors.surface(context),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: TevioDimensions.navigationHeight,
          child: Row(
            children: [
              for (var index = 0; index < _items.length; index++)
                Expanded(
                  child: _NavigationButton(
                    item: _items[index],
                    selected: currentIndex == index,
                    onPressed: () => onDestinationSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? TevioColors.primary
        : TevioThemeColors.secondaryText(context);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: TevioMotion.fast,
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      key: ValueKey(selected),
                      color: color,
                      size: 25,
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    child: AnimatedContainer(
                      duration: TevioMotion.fast,
                      width: selected ? 16 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: TevioColors.mint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
