import 'package:ecommerce/models/order_model.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<List<OrderModel>>(
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
                Icon(Icons.receipt_long_outlined, size: 80, color: color.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.inversePrimary)),
                const SizedBox(height: 8),
                Text('Your order history will appear here.', style: TextStyle(color: color.inversePrimary.withOpacity(0.5))),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100),
          itemCount: orders.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Order History',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.inversePrimary)),
              );
            }

            final order = orders[index - 1];
            final statusColor = _statusColor(order.status);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ORD-${order.shortId}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color.inversePrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text(order.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Order items summary
                  ...order.items.take(2).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(color: color.primary.withOpacity(0.5), shape: BoxShape.circle),
                            ),
                            Expanded(
                              child: Text(
                                '${item['title']} x${item['quantity']}',
                                style: TextStyle(fontSize: 13, color: color.inversePrimary.withOpacity(0.7)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\$${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.inversePrimary),
                            ),
                          ],
                        ),
                      )),
                  if (order.items.length > 2)
                    Text(
                      '+${order.items.length - 2} more items',
                      style: TextStyle(fontSize: 12, color: color.primary, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 12),
                  Divider(color: color.primary.withOpacity(0.1)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date', style: TextStyle(color: color.inversePrimary.withOpacity(0.5), fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(order.formattedDate, style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary, fontSize: 13)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total', style: TextStyle(color: color.inversePrimary.withOpacity(0.5), fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: color.primary, fontSize: 16),
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
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
