import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Product> _items = [];
  Set<String> _wishlistIds = {};

  List<Product> get items => _items;
  int get itemCount => _items.length;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void startListening() {
    final uid = _uid;
    if (uid == null) return;
    _service.getWishlist(uid).listen((items) {
      _items = items;
      _wishlistIds = items.map((p) => p.id).toSet();
      notifyListeners();
    });
  }

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);

  Future<void> toggleWishlist(Product product) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.toggleWishlist(uid, product);
  }
}
