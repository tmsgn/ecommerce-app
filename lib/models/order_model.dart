import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String status;
  final String address;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.address,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId: doc.id,
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Processing',
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  String get shortId => orderId.substring(0, 8).toUpperCase();
}
