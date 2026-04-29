import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.primary.withOpacity(isDarkMode ? 0.2 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
        child: GNav(
          rippleColor: color.primary.withOpacity(0.15),
          hoverColor: color.primary.withOpacity(0.1),
          gap: 6,
          activeColor: color.primary,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: color.primary.withOpacity(0.12),
          color: color.inversePrimary.withOpacity(0.4),
          textStyle: TextStyle(
            color: color.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            GButton(icon: Icons.home_rounded, text: 'Home'),
            GButton(icon: Icons.grid_view_rounded, text: 'Categories'),
            GButton(icon: Icons.favorite_rounded, text: 'Wishlist'),
            GButton(icon: Icons.receipt_long_rounded, text: 'Orders'),
            GButton(icon: Icons.person_rounded, text: 'Profile'),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}
