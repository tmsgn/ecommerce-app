import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isWished = wishlist.isInWishlist(widget.product.id);
    final isInCart = cart.isInCart(widget.product.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? color.tertiary.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new, color: color.inversePrimary, size: 18),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => wishlist.toggleWishlist(widget.product),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? color.tertiary.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWished ? Icons.favorite : Icons.favorite_border,
                color: isWished ? Colors.red : color.inversePrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Product Image
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Hero
                  Container(
                    height: 320,
                    width: double.infinity,
                    color: isDark ? color.tertiary : const Color(0xFFF0EEFF),
                    child: widget.product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(color: color.primary),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_outlined,
                              size: 80,
                              color: color.primary.withOpacity(0.4),
                            ),
                          )
                        : Icon(Icons.image_outlined, size: 100, color: color.primary.withOpacity(0.3)),
                  ),
                  // ── Details Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.product.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: color.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Title & Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.product.title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: color.inversePrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '\$${widget.product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Rating & Stock
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (i) {
                                  final full = i < widget.product.rating.floor();
                                  final half = !full && i < widget.product.rating;
                                  return Icon(
                                    full ? Icons.star : half ? Icons.star_half : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.product.rating.toStringAsFixed(1)} rating',
                                style: TextStyle(
                                  color: color.inversePrimary.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.product.stock > 0
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.product.stock > 0
                                      ? '${widget.product.stock} in stock'
                                      : 'Out of stock',
                                  style: TextStyle(
                                    color: widget.product.stock > 0 ? Colors.green : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(color: color.primary.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color.inversePrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: color.inversePrimary.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Quantity selector
                          Row(
                            children: [
                              Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: color.inversePrimary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? color.tertiary : const Color(0xFFF5F4FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _qtyButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (_quantity > 1) setState(() => _quantity--);
                                      },
                                      color: color,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '$_quantity',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: color.inversePrimary,
                                        ),
                                      ),
                                    ),
                                    _qtyButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        if (_quantity < widget.product.stock) {
                                          setState(() => _quantity++);
                                        }
                                      },
                                      color: color,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Total
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(fontSize: 12, color: color.inversePrimary.withOpacity(0.5))),
                Text(
                  '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.primary),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.stock == 0
                    ? null
                    : () async {
                        for (int i = 0; i < _quantity; i++) {
                          await cart.addToCart(widget.product);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Added to cart!'),
                              backgroundColor: color.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                icon: Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart, size: 20),
                label: Text(isInCart ? 'Add More' : 'Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap, required ColorScheme color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: color.primary),
      ),
    );
  }
}
