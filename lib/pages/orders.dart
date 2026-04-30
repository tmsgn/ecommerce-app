import 'package:ecommerce/models/order_model.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text('Orders', style: Theme.of(context).textTheme.displaySmall),
        centerTitle: false,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService().getOrders(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snap.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: color.tertiary),
                  const SizedBox(height: 24),
                  Text('No orders yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Your order history will appear here.', style: TextStyle(color: color.secondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusColor = _statusColor(order.status, color);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: color.tertiary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ORD-${order.shortId}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color.inversePrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...order.items.take(2).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text('${item['quantity']}x ', style: TextStyle(fontWeight: FontWeight.w600, color: color.secondary, fontSize: 13)),
                              Expanded(
                                child: Text(
                                  '${item['title']}',
                                  style: TextStyle(fontSize: 13, color: color.inversePrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color.inversePrimary),
                              ),
                            ],
                          ),
                        )),
                    if (order.items.length > 2)
                      Text(
                        '+${order.items.length - 2} more items',
                        style: TextStyle(fontSize: 12, color: color.secondary, fontStyle: FontStyle.italic),
                      ),
                    const SizedBox(height: 16),
                    Divider(color: color.tertiary, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DATE', style: TextStyle(color: color.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(order.formattedDate, style: TextStyle(fontWeight: FontWeight.w500, color: color.inversePrimary, fontSize: 13)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('TOTAL', style: TextStyle(color: color.secondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColor(String status, ColorScheme color) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return color.error;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
