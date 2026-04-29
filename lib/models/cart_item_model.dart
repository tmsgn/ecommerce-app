import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      productId: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  double get totalPrice => price * quantity;
}
