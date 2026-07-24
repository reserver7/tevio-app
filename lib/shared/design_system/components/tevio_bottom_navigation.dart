import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_radius.dart';

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
    _NavigationItem(Icons.inventory_2_outlined, Icons.inventory_2, '내 제품'),
    _NavigationItem(Icons.add_circle_outline, Icons.add_circle, '등록'),
    _NavigationItem(Icons.person_outline, Icons.person, '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TevioColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
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
    final color = selected ? TevioColors.primary : TevioColors.textTertiary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: IconButton(
        tooltip: item.label,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          backgroundColor: selected
              ? TevioColors.primaryBackground
              : TevioColors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: TevioRadius.fullBorder,
          ),
        ),
        icon: Icon(selected ? item.selectedIcon : item.icon, color: color),
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
