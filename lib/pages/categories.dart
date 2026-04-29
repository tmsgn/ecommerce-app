import 'package:ecommerce/components/product_card.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String? _selectedCategory;
  final FirestoreService _service = FirestoreService();

  final List<Map<String, dynamic>> categories = [
    {'title': 'Fashion', 'icon': Icons.checkroom, 'color': const Color(0xFFFFE0EC)},
    {'title': 'Electronics', 'icon': Icons.phone_iphone, 'color': const Color(0xFFFFEDD8)},
    {'title': 'Home & Living', 'icon': Icons.chair, 'color': const Color(0xFFD8F5E9)},
    {'title': 'Beauty', 'icon': Icons.face_retouching_natural, 'color': const Color(0xFFEDE0FF)},
    {'title': 'Sports', 'icon': Icons.sports_soccer, 'color': const Color(0xFFD8EEFF)},
    {'title': 'Toys', 'icon': Icons.toys, 'color': const Color(0xFFFFF9C4)},
    {'title': 'Groceries', 'icon': Icons.local_grocery_store, 'color': const Color(0xFFD0F5F5)},
    {'title': 'Books', 'icon': Icons.menu_book, 'color': const Color(0xFFEDD8C8)},
    {'title': 'Automotive', 'icon': Icons.directions_car, 'color': const Color(0xFFFFD8D8)},
    {'title': 'Music', 'icon': Icons.music_note, 'color': const Color(0xFFDDD8FF)},
    {'title': 'Gaming', 'icon': Icons.videogame_asset, 'color': const Color(0xFFD8F0FF)},
    {'title': 'Health', 'icon': Icons.medical_services, 'color': const Color(0xFFD8FFF0)},
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              'All Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.inversePrimary),
            ),
          ),
        ),

        // Category Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat['title'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = isSelected ? null : cat['title'];
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.primary
                                : (isDark
                                    ? (cat['color'] as Color).withOpacity(0.15)
                                    : cat['color'] as Color),
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.primary.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Center(
                            child: Icon(
                              cat['icon'] as IconData,
                              size: 28,
                              color: isSelected ? Colors.white : (isDark ? (cat['color'] as Color) : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? color.primary : color.inversePrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Products for selected category
        if (_selectedCategory != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Text(
                    _selectedCategory!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.inversePrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Products', style: TextStyle(fontSize: 12, color: color.primary)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Product>>(
              stream: _service.getProductsByCategory(_selectedCategory!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final products = snap.data ?? [];
                if (products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: color.primary.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'No products in this category yet',
                            style: TextStyle(color: color.inversePrimary.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => ProductCard(product: products[i]),
                  ),
                );
              },
            ),
          ),
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
