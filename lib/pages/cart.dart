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
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text('Cart', style: Theme.of(context).textTheme.displaySmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: color.inversePrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => cart.clearCart(),
              child: Text('Clear', style: TextStyle(color: color.secondary, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context, color)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: color.tertiary, height: 1),
                    ),
                    itemBuilder: (context, index) => _CartItemTile(item: cart.items[index]),
                  ),
                ),
                _buildOrderSummary(context, cart, color),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: color.tertiary),
          const SizedBox(height: 24),
          Text('Your cart is empty', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Add some items to get started.', style: TextStyle(color: color.secondary)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart, ColorScheme color) {
    final subtotal = cart.totalAmount;
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(top: BorderSide(color: color.tertiary, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color.inversePrimary, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', color),
          const SizedBox(height: 12),
          _summaryRow('Shipping', shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}', color),
          const SizedBox(height: 16),
          Divider(color: color.tertiary, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color.inversePrimary)),
              Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color.inversePrimary)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CheckoutPage(cartItems: cart.items, totalAmount: total)),
              ),
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, ColorScheme color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: color.secondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color.inversePrimary)),
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
    final cart = context.read<CartProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 80,
            height: 100,
            color: color.tertiary.withOpacity(0.3),
            child: item.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(Icons.image_outlined, color: color.inversePrimary.withOpacity(0.2)),
                  )
                : Icon(Icons.image_outlined, color: color.inversePrimary.withOpacity(0.2)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: color.tertiary),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        _qtyBtn(Icons.remove, () => cart.updateQuantity(item.productId, item.quantity - 1), color),
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary)),
                        ),
                        _qtyBtn(Icons.add, () => cart.updateQuantity(item.productId, item.quantity + 1), color),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cart.removeFromCart(item.productId),
                    child: Text(
                      'Remove',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.secondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, ColorScheme color) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon, size: 14, color: color.inversePrimary),
      ),
    );
  }
}
