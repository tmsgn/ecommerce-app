import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/models/product_model.dart';

import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/pages/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final wishlist = context.watch<WishlistProvider>();
    final isWished = wishlist.isInWishlist(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.tertiary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section (takes up majority of the card)
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Container(
                      color: color.tertiary.withOpacity(0.3),
                      child: product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: color.inversePrimary.withOpacity(0.2)),
                            )
                          : Icon(Icons.image_outlined, color: color.inversePrimary.withOpacity(0.2)),
                    ),
                  ),
                  // Wishlist button (Subtle)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => wishlist.toggleWishlist(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: color.tertiary, width: 0.5),
                        ),
                        child: Icon(
                          isWished ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isWished ? color.error : color.inversePrimary,
                        ),
                      ),
                    ),
                  ),
                  // Best seller badge (Sleek)
                  if (product.isBestSeller)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BESTSELLER',
                          style: TextStyle(
                            color: color.onPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            color: color.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color.inversePrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: color.inversePrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
