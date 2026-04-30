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

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text('Wishlist', style: Theme.of(context).textTheme.displaySmall),
        centerTitle: false,
        actions: [
          if (wishlist.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${wishlist.itemCount} items',
                  style: TextStyle(color: color.secondary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: color.tertiary),
                  const SizedBox(height: 24),
                  Text('Your wishlist is empty', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Tap the heart on any product to save it.', style: TextStyle(color: color.secondary)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (ctx, i) => ProductCard(product: wishlist.items[i]),
            ),
    );
  }
}
