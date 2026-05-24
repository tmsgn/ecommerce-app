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
    final snap = await _db.collection('products').get();

    if (snap.docs.isNotEmpty) {
      // Deduplicate: remove extra docs with the same title, keep the first
      final seen = <String>{};
      final batch = _db.batch();
      bool hasDups = false;
      for (final doc in snap.docs) {
        final title = doc.data()['title'] as String? ?? '';
        if (seen.contains(title)) {
          batch.delete(doc.reference);
          hasDups = true;
        } else {
          seen.add(title);
        }
      }
      if (hasDups) await batch.commit();

      // Migrate prices: if any product has price < 1000, scale it by 100 to be realistic ETB
      final priceBatch = _db.batch();
      bool hasPriceMigration = false;
      for (final doc in snap.docs) {
        final data = doc.data();
        final priceVal = (data['price'] as num?)?.toDouble() ?? 0.0;
        if (priceVal < 1000) {
          final newPrice = (priceVal * 100).roundToDouble();
          priceBatch.update(doc.reference, {'price': newPrice});
          hasPriceMigration = true;
        }
      }
      if (hasPriceMigration) await priceBatch.commit();

      // Fix any broken image URLs
      await patchBrokenImageUrls();
      return;
    }

    final products = _getSeedProducts();
    final writeBatch = _db.batch();
    for (final p in products) {
      final ref = _db.collection('products').doc();
      final basePrice = (p['price'] as num?)?.toDouble() ?? 0.0;
      final scaledPrice = (basePrice * 100).roundToDouble();
      final pCopy = Map<String, dynamic>.from(p);
      pCopy['price'] = scaledPrice;
      writeBatch.set(ref, pCopy);
    }
    await writeBatch.commit();
  }

  /// Updates imageUrls for all products by matching on title.
  /// Runs every launch to fix any broken URLs.
  Future<void> patchBrokenImageUrls() async {
    const titleToImage = {
      'Wireless Noise-Cancelling Headphones':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
      'Smart Watch Pro':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80',
      'Bluetooth Speaker':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&auto=format&fit=crop&q=80',
      'Mechanical Keyboard':
          'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=600&auto=format&fit=crop&q=80',
      'Classic Leather Jacket':
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&auto=format&fit=crop&q=80',
      'Premium Running Sneakers':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
      'Casual Backpack':
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80',
      'Coffee Maker Deluxe':
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&auto=format&fit=crop&q=80',
      'Scented Candle Set':
          'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=600&auto=format&fit=crop&q=80',
      'Ergonomic Office Chair':
          'https://images.unsplash.com/photo-1505797149-43b0069ec26b?w=600&auto=format&fit=crop&q=80',
      'Vitamin C Serum':
          'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=600&auto=format&fit=crop&q=80',
      'Luxury Perfume':
          'https://images.unsplash.com/photo-1541643600914-78b084683601?w=600&auto=format&fit=crop&q=80',
      'Fitness Resistance Bands':
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
      'Yoga Mat Premium':
          'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=600&auto=format&fit=crop&q=80',
      'LEGO Architecture Set':
          'https://images.unsplash.com/photo-1560942485-b2a11cc13456?w=600&auto=format&fit=crop&q=80',
      'Remote Control Car':
          'https://images.unsplash.com/photo-1594786118579-95ba90c801ec?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1603006905003-be475563bc59?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1505797149-43b0069ec26b?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1541643600914-78b084683601?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1560942485-b2a11cc13456?w=600&auto=format&fit=crop&q=80',
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
            'https://images.unsplash.com/photo-1594786118579-95ba90c801ec?w=600&auto=format&fit=crop&q=80',
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

  // ─── Shipping Addresses ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAddressesOnce(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: false)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Stream<List<Map<String, dynamic>>> getAddresses(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  Future<void> addAddress(String uid, Map<String, dynamic> address) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .add({...address, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  Future<void> setDefaultAddress(String uid, String addressId) async {
    // Clear existing defaults then set new one
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }
    await batch.commit();
  }

  // ─── Payment Methods ──────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> getPaymentMethods(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  Future<void> addPaymentMethod(
      String uid, Map<String, dynamic> method) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .add({...method, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> deletePaymentMethod(String uid, String methodId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .doc(methodId)
        .delete();
  }
}
