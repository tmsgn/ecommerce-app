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
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final isWished = wishlist.isInWishlist(widget.product.id);
    final isInCart = cart.isInCart(widget.product.id);

    return Scaffold(
      backgroundColor: color.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.surface.withOpacity(0.9),
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
                color: color.surface.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWished ? Icons.favorite : Icons.favorite_border,
                color: isWished ? color.error : color.inversePrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                    height: 400,
                    width: double.infinity,
                    color: color.tertiary.withOpacity(0.3),
                    child: widget.product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(color: color.primary),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: color.tertiary,
                            ),
                          )
                        : Icon(Icons.image_outlined, size: 100, color: color.tertiary),
                  ),
                  
                  // ── Details Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Text(
                          widget.product.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: color.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Title
                        Text(
                          widget.product.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        
                        // Price & Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '\$${widget.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color.inversePrimary,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: color.inversePrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        Divider(color: color.tertiary, height: 1),
                        const SizedBox(height: 32),
                        
                        // Description
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color.inversePrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.product.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: color.secondary,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Quantity selector
                        Row(
                          children: [
                            Text(
                              'QUANTITY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color.inversePrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: color.tertiary),
                                borderRadius: BorderRadius.circular(8),
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
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$_quantity',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
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
                        const SizedBox(height: 120), // Padding for bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: color.surface,
          border: Border(top: BorderSide(color: color.tertiary, width: 0.5)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(fontSize: 12, color: color.secondary)),
                Text(
                  '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.inversePrimary),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.stock == 0
                    ? null
                    : () async {
                        for (int i = 0; i < _quantity; i++) {
                          await cart.addToCart(widget.product);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Added to cart'),
                              backgroundColor: color.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? color.surface : color.primary,
                  foregroundColor: isInCart ? color.primary : color.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  side: isInCart ? BorderSide(color: color.primary, width: 2) : BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isInCart ? 'Add More' : 'Add to Cart',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap, required ColorScheme color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 18, color: color.inversePrimary),
      ),
    );
  }
}
