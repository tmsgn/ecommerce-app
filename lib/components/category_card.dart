import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = Theme.of(context).colorScheme;

    return SizedBox(
      width: 75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? backgroundColor.withOpacity(0.2)
                  : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 32,
                color: isDarkMode
                    ? backgroundColor.withOpacity(0.9)
                    : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
