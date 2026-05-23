import 'package:ecommerce/components/product_card.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  final String? initialCategory;
  const CategoriesPage({super.key, this.initialCategory});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String? _selectedCategory;
  final FirestoreService _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(covariant CategoriesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      _selectedCategory = widget.initialCategory;
    }
  }

  final List<Map<String, dynamic>> categories = [
    {'title': 'Fashion', 'icon': Icons.checkroom},
    {'title': 'Electronics', 'icon': Icons.phone_iphone},
    {'title': 'Home', 'icon': Icons.chair_outlined},
    {'title': 'Beauty', 'icon': Icons.face_retouching_natural},
    {'title': 'Sports', 'icon': Icons.sports_soccer},
    {'title': 'Toys', 'icon': Icons.toys_outlined},
    {'title': 'Groceries', 'icon': Icons.local_grocery_store_outlined},
    {'title': 'Books', 'icon': Icons.menu_book_outlined},
    {'title': 'Auto', 'icon': Icons.directions_car_outlined},
    {'title': 'Music', 'icon': Icons.music_note_outlined},
    {'title': 'Gaming', 'icon': Icons.videogame_asset_outlined},
    {'title': 'Health', 'icon': Icons.medical_services_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: color.surface,
          title: Text('Categories', style: Theme.of(context).textTheme.displaySmall),
          centerTitle: false,
          floating: true,
          elevation: 0,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat['title'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = isSelected ? null : cat['title'];
                  }),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? color.primary : color.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? color.primary : color.tertiary,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            cat['icon'] as IconData,
                            size: 24,
                            color: isSelected ? color.onPrimary : color.inversePrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? color.primary : color.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Divider
        if (_selectedCategory != null)
          SliverToBoxAdapter(
            child: Divider(color: color.tertiary, height: 32),
          ),

        // Products for selected category
        if (_selectedCategory != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${_selectedCategory!} Collection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Product>>(
              stream: _service.getProductsByCategory(_selectedCategory!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final products = snap.data ?? [];
                if (products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: color.tertiary),
                          const SizedBox(height: 16),
                          Text('No items found in this category', style: TextStyle(color: color.secondary)),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => ProductCard(product: products[i]),
                  ),
                );
              },
            ),
          ),
        ] else
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
