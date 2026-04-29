import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce/models/cart_item_model.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/pages/checkout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: color.inversePrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => cart.clearCart(),
              child: Text('Clear all', style: TextStyle(color: color.secondary)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context, color)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) => _CartItemTile(item: cart.items[index]),
                  ),
                ),
                _buildOrderSummary(context, cart, color, isDark),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: color.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.inversePrimary)),
          const SizedBox(height: 8),
          Text('Add some products to get started!', style: TextStyle(color: color.inversePrimary.withOpacity(0.5))),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Start Shopping')),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart, ColorScheme color, bool isDark) {
    final subtotal = cart.totalAmount;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color.inversePrimary)),
          const SizedBox(height: 12),
          _summaryRow('Subtotal (${cart.itemCount} items)', '\$${subtotal.toStringAsFixed(2)}', color),
          const SizedBox(height: 6),
          _summaryRow('Shipping', shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}', color,
              valueColor: shipping == 0 ? Colors.green : null),
          if (shipping > 0) ...[
            const SizedBox(height: 4),
            Text('Free shipping on orders over \$50', style: const TextStyle(fontSize: 11, color: Colors.green, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 12),
          Divider(color: color.primary.withOpacity(0.1)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color.inversePrimary)),
              Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color.primary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CheckoutPage(cartItems: cart.items, totalAmount: total)),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, ColorScheme color, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: color.inversePrimary.withOpacity(0.6))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? color.inversePrimary)),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: isDark ? color.tertiary : const Color(0xFFF0EEFF),
              child: item.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: color.primary.withOpacity(0.3)),
                    )
                  : Icon(Icons.image_outlined, color: color.primary.withOpacity(0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary)),
                const SizedBox(height: 4),
                Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(color: color.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _qtyBtn(Icons.remove, () => cart.updateQuantity(item.productId, item.quantity - 1), color),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary)),
                    ),
                    _qtyBtn(Icons.add, () => cart.updateQuantity(item.productId, item.quantity + 1), color),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => cart.removeFromCart(item.productId),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 16),
              Text('\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color.inversePrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, ColorScheme color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: color.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: color.primary),
      ),
    );
  }
}
