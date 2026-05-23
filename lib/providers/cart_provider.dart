import 'dart:async';
import 'package:ecommerce/models/cart_item_model.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<CartItem> _items = [];
  bool _isLoading = false;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<CartItem>>? _cartSubscription;

  CartProvider() {
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _startListening(user.uid);
      } else {
        _stopListening();
      }
    });
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _startListening(String uid) {
    _cartSubscription?.cancel();
    _isLoading = true;
    _cartSubscription = _service.getCart(uid).listen((items) {
      _items = items;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void _stopListening() {
    _cartSubscription?.cancel();
    _cartSubscription = null;
    _items = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.addToCart(uid, product, quantity: quantity);
  }

  Future<void> removeFromCart(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.removeFromCart(uid, productId);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.updateCartQuantity(uid, productId, quantity);
  }

  Future<void> clearCart() async {
    final uid = _uid;
    if (uid == null) return;
    await _service.clearCart(uid);
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cartSubscription?.cancel();
    super.dispose();
  }
}
