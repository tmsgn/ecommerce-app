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
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
        child: GNav(
          rippleColor: Colors.grey.shade300,
          hoverColor: Colors.grey.shade100,
          gap: 6,
          activeColor: const Color(0xFF5A44FF), // Purple matched to active icon
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: const Color(0xFF5A44FF).withOpacity(0.1),
          color: Colors.grey.shade600,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.grid_view_rounded,
              text: 'Categories',
            ),
            GButton(
              icon: Icons.favorite_border,
              text: 'Wishlist',
            ),
            GButton(
              icon: Icons.shopping_bag_outlined,
              text: 'Orders',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Profile',
            ),
          ],
          selectedIndex: selectedIndex,
          onTabChange: onTabChange,
        ),
      ),
    );
  }
}
