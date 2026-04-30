import 'package:flutter/material.dart';

class BottomTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const BottomTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(top: BorderSide(color: color.tertiary, width: 0.5)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: color.surface,
          indicatorColor: color.primary.withOpacity(0.08),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.primary);
            }
            return TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color.secondary);
          }),
        ),
        child: NavigationBar(
          height: 65,
          elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: onTabChange,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: color.secondary),
              selectedIcon: Icon(Icons.home, color: color.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: color.secondary),
              selectedIcon: Icon(Icons.grid_view, color: color.primary),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border, color: color.secondary),
              selectedIcon: Icon(Icons.favorite, color: color.primary),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: color.secondary),
              selectedIcon: Icon(Icons.receipt_long, color: color.primary),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: color.secondary),
              selectedIcon: Icon(Icons.person, color: color.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
