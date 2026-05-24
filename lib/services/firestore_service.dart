import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/cart_item_model.dart';
import 'package:ecommerce/models/order_model.dart';
import 'package:ecommerce/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Products ────────────────────────────────────────────────────────────

  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map(
          (snap) => snap.docs.map(Product.fromFirestore).toList(),
        );
  }

  Stream<List<Product>> getFeaturedProducts() {
    return _db
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(Product.fromFirestore).toList());
  }

  Stream<List<Product>> getBestSellerProducts() {
    return _db
        .collection('products')
        .where('isBestSeller', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(Product.fromFirestore).toList());
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snap) => snap.docs.map(Product.fromFirestore).toList());
  }

  Future<List<Product>> searchProducts(String query) async {
    final snap = await _db.collection('products').get();
    final all = snap.docs.map(Product.fromFirestore).toList();
    final lower = query.toLowerCase();
    return all
        .where((p) =>
            p.title.toLowerCase().contains(lower) ||
            p.category.toLowerCase().contains(lower))
        .toList();
  }

  // ─── Seed Products ────────────────────────────────────────────────────────

  Future<void> seedProductsIfEmpty() async {
    final snap = await _db.collection('products').limit(1).get();
    if (snap.docs.isNotEmpty) {
      // Already seeded — patch any broken image URLs
      await patchBrokenImageUrls();
      return;
    }

    final products = _getSeedProducts();
    final batch = _db.batch();
    for (final p in products) {
      final ref = _db.collection('products').doc();
      batch.set(ref, p);
    }
    await batch.commit();
  }

  /// Updates imageUrls for all products by matching on title.
  /// Runs every launch to fix any broken URLs.
  Future<void> patchBrokenImageUrls() async {
    // Map of product title → correct working image URL
    const titleToImage = {
      'Wireless Noise-Cancelling Headphones':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      'Smart Watch Pro':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      'Bluetooth Speaker':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
      'Mechanical Keyboard':
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400',
      'Classic Leather Jacket':
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400',
      'Premium Running Sneakers':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      'Casual Backpack':
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      'Coffee Maker Deluxe':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
      'Scented Candle Set':
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400',
      'Ergonomic Office Chair':
          'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=400',
      'Vitamin C Serum':
          'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=400',
      'Luxury Perfume':
          'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?w=400',
      'Fitness Resistance Bands':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      'Yoga Mat Premium':
          'https://images.unsplash.com/photo-1506126613408-eca07ce68779?w=400',
      'LEGO Architecture Set':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      'Remote Control Car':
          'https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?w=400',
    };

    final snap = await _db.collection('products').get();
    final batch = _db.batch();
    bool hasChanges = false;

    for (final doc in snap.docs) {
      final title = doc.data()['title'] as String? ?? '';
      final correctUrl = titleToImage[title];
      if (correctUrl != null && doc.data()['imageUrl'] != correctUrl) {
        batch.update(doc.reference, {'imageUrl': correctUrl});
        hasChanges = true;
      }
    }

    if (hasChanges) await batch.commit();
  }

  List<Map<String, dynamic>> _getSeedProducts() {
    return [
      // ── Electronics
      {
        'title': 'Wireless Noise-Cancelling Headphones',
        'price': 79.99,
        'rating': 4.7,
        'category': 'Electronics',
        'description':
            'Premium wireless headphones with active noise cancellation, 30-hour battery life, and crystal-clear audio. Perfect for work, travel, and everything in between.',
        'imageUrl':
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'isFeatured': true,
        'isBestSeller': false,
        'stock': 25,
      },
      {
        'title': 'Smart Watch Pro',
        'price': 129.99,
        'rating': 4.5,
        'category': 'Electronics',
        'description':
            'Feature-packed smartwatch with health monitoring, GPS tracking, 5-day battery, and a gorgeous AMOLED display.',
        'imageUrl':
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        'isFeatured': true,
        'isBestSeller': true,
        'stock': 18,
      },
      {
        'title': 'Bluetooth Speaker',
        'price': 49.99,
        'rating': 4.4,
        'category': 'Electronics',
        'description':
            '360° surround sound, waterproof design, and 12-hour playtime. The perfect companion for outdoor adventures.',
        'imageUrl':
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
        'isFeatured': false,
        'isBestSeller': true,
        'stock': 30,
      },
      {
        'title': 'Mechanical Keyboard',
        'price': 89.99,
        'rating': 4.6,
        'category': 'Electronics',
        'description':
            'TKL mechanical keyboard with RGB backlight, tactile switches, and a durable aluminum frame for pro gamers and typists.',
        'imageUrl':
            'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400',
        'isFeatured': false,
        'isBestSeller': false,
        'stock': 15,
      },
      // ── Fashion
      {
        'title': 'Classic Leather Jacket',
        'price': 149.99,
        'rating': 4.8,
        'category': 'Fashion',
        'description':
            'Genuine leather jacket with a timeless biker silhouette. Soft inner lining, heavy-duty zipper, and a perfect slim fit.',
        'imageUrl':
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        'isFeatured': true,
        'isBestSeller': true,
        'stock': 12,
      },
      {
        'title': 'Premium Running Sneakers',
        'price': 69.99,
        'rating': 4.5,
        'category': 'Fashion',
        'description':
            'Lightweight and breathable sneakers with cushioned sole technology. Built for performance and all-day comfort.',
        'imageUrl':
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'isFeatured': false,
        'isBestSeller': true,
        'stock': 22,
      },
      {
        'title': 'Casual Backpack',
        'price': 44.99,
        'rating': 4.3,
        'category': 'Fashion',
        'description':
            'Spacious 30L backpack with laptop compartment, USB charging port, and ergonomic shoulder straps.',
        'imageUrl':
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
        'isFeatured': false,
        'isBestSeller': false,
        'stock': 28,
      },
      // ── Home & Living
      {
        'title': 'Coffee Maker Deluxe',
        'price': 89.99,
        'rating': 4.6,
        'category': 'Home & Living',
        'description':
            'Brew barista-quality coffee at home. Programmable timer, thermal carafe, and built-in grinder included.',
        'imageUrl':
            'https://images.unsplash.com/photo-1512568400610-62da28bc8a13?w=400',
        'isFeatured': true,
        'isBestSeller': false,
        'stock': 10,
      },
      {
        'title': 'Scented Candle Set',
        'price': 29.99,
        'rating': 4.4,
        'category': 'Home & Living',
        'description':
            'Set of 3 hand-poured soy candles with calming lavender, vanilla, and sandalwood fragrances. 50-hour burn time each.',
        'imageUrl':
            'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400',
        'isFeatured': false,
        'isBestSeller': true,
        'stock': 40,
      },
      {
        'title': 'Ergonomic Office Chair',
        'price': 299.99,
        'rating': 4.7,
        'category': 'Home & Living',
        'description':
            'Fully adjustable lumbar support, breathable mesh back, and 360° swivel. Work comfortably for hours.',
        'imageUrl':
            'https://images.unsplash.com/photo-1567538096621-38d2284b23ff?w=400',
        'isFeatured': true,
        'isBestSeller': false,
        'stock': 8,
      },
      // ── Beauty
      {
        'title': 'Vitamin C Serum',
        'price': 34.99,
        'rating': 4.6,
        'category': 'Beauty',
        'description':
            'Brightening serum with 20% Vitamin C, hyaluronic acid, and niacinamide. Reduces dark spots and boosts radiance.',
        'imageUrl':
            'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
        'isFeatured': false,
        'isBestSeller': true,
        'stock': 35,
      },
      {
        'title': 'Luxury Perfume',
        'price': 79.99,
        'rating': 4.8,
        'category': 'Beauty',
        'description':
            'A sophisticated blend of jasmine, bergamot, and sandalwood. Long-lasting 12-hour fragrance in a premium glass bottle.',
        'imageUrl':
            'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=400',
        'isFeatured': true,
        'isBestSeller': false,
        'stock': 20,
      },
      // ── Sports
      {
        'title': 'Fitness Resistance Bands',
        'price': 19.99,
        'rating': 4.4,
        'category': 'Sports',
        'description':
            'Set of 5 resistance bands with varying tension levels. Ideal for home workouts, stretching, and physical therapy.',
        'imageUrl':
            'https://images.unsplash.com/photo-1598971861713-54ad16a7e72e?w=400',
        'isFeatured': false,
        'isBestSeller': true,
        'stock': 50,
      },
      {
        'title': 'Yoga Mat Premium',
        'price': 39.99,
        'rating': 4.5,
        'category': 'Sports',
        'description':
            '6mm thick eco-friendly non-slip yoga mat with alignment lines and carrying strap. Perfect for yoga, pilates, and stretching.',
        'imageUrl':
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
        'isFeatured': false,
        'isBestSeller': false,
        'stock': 45,
      },
      // ── Toys
      {
        'title': 'LEGO Architecture Set',
        'price': 59.99,
        'rating': 4.7,
        'category': 'Toys',
        'description':
            '780-piece LEGO set to build iconic skylines. Perfect for ages 12+ and adult collectors who love detailed builds.',
        'imageUrl':
            'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400',
        'isFeatured': true,
        'isBestSeller': false,
        'stock': 16,
      },
      {
        'title': 'Remote Control Car',
        'price': 34.99,
        'rating': 4.3,
        'category': 'Toys',
        'description':
            'High-speed 1:16 scale RC car with 4WD, 2.4GHz remote, and 30min runtime. Great for kids 6+.',
        'imageUrl':
            'https://images.unsplash.com/photo-1594751543129-6701ad444259?w=400',
        'isFeatured': false,
        'isBestSeller': true,
        'stock': 22,
      },
    ];
  }

  // ─── User Profile ─────────────────────────────────────────────────────────

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String photoURL = '',
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── Cart ─────────────────────────────────────────────────────────────────

  Stream<List<CartItem>> getCart(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map((snap) => snap.docs.map(CartItem.fromFirestore).toList());
  }

  Future<void> addToCart(String uid, Product product, {int quantity = 1}) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(product.id);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.update({'quantity': FieldValue.increment(quantity)});
    } else {
      await ref.set({
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
      });
    }
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  Future<void> updateCartQuantity(
      String uid, String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(uid, productId);
    } else {
      await _db
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});
    }
  }

  Future<void> clearCart(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── Wishlist ─────────────────────────────────────────────────────────────

  Stream<List<Product>> getWishlist(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) {
              final data = doc.data();
              return Product(
                id: doc.id,
                title: data['title'] ?? '',
                price: (data['price'] as num?)?.toDouble() ?? 0.0,
                rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
                category: data['category'] ?? '',
                description: data['description'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
              );
            })
            .toList());
  }

  Future<bool> isInWishlist(String uid, String productId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .get();
    return doc.exists;
  }

  Future<void> toggleWishlist(String uid, Product product) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(product.id);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'title': product.title,
        'price': product.price,
        'rating': product.rating,
        'category': product.category,
        'description': product.description,
        'imageUrl': product.imageUrl,
      });
    }
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  Stream<List<OrderModel>> getOrders(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Future<void> placeOrder({
    required String uid,
    required List<CartItem> cartItems,
    required double totalAmount,
    required String address,
  }) async {
    await _db.collection('users').doc(uid).collection('orders').add({
      'items': cartItems
          .map((item) => {
                'productId': item.productId,
                'title': item.title,
                'price': item.price,
                'quantity': item.quantity,
                'imageUrl': item.imageUrl,
              })
          .toList(),
      'totalAmount': totalAmount,
      'status': 'Processing',
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await clearCart(uid);
  }
}
