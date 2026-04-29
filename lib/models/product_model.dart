import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final double rating;
  final String category;
  final String description;
  final String imageUrl;
  final bool isFeatured;
  final bool isBestSeller;
  final int stock;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.stock = 10,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isBestSeller: data['isBestSeller'] ?? false,
      stock: (data['stock'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'rating': rating,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
      'stock': stock,
    };
  }
}
