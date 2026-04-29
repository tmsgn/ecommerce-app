import 'package:ecommerce/components/product_card.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final wishlist = context.watch<WishlistProvider>();

    return wishlist.items.isEmpty
        ? _buildEmpty(context, color)
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Wishlist',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.inversePrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${wishlist.itemCount} items',
                          style: TextStyle(color: color.primary, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ProductCard(product: wishlist.items[i]),
                    childCount: wishlist.items.length,
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildEmpty(BuildContext context, ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: color.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No saved items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.inversePrimary)),
          const SizedBox(height: 8),
          Text('Tap ♡ on any product to save it here.', style: TextStyle(color: color.inversePrimary.withOpacity(0.5))),
        ],
      ),
    );
  }
}
