import 'package:ecommerce/models/cart_item_model.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPlacingOrder = false;
  String _selectedPayment = 'telebirr';

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final addresses = await FirestoreService().getAddressesOnce(uid);
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (addr) => addr['isDefault'] == true,
          orElse: () => addresses.first,
        );
        setState(() {
          final user = FirebaseAuth.instance.currentUser;
          _nameController.text = user?.displayName ?? defaultAddress['label'] ?? 'Home';
          _phoneController.text = defaultAddress['phone'] ?? '';
          _addressController.text = defaultAddress['street'] ?? '';
          _cityController.text = defaultAddress['city'] ?? '';
        });
      }
    } catch (e) {
      // Background populating error is silently handled
    }
  }

  static const _paymentMethods = [
    _PaymentMethod(
      id: 'telebirr',
      name: 'TeleBirr',
      subtitle: 'Ethio Telecom mobile payment',
      icon: Icons.phone_android,
      color: Color(0xFF00A651),
    ),
    _PaymentMethod(
      id: 'cbebirr',
      name: 'CBE Birr',
      subtitle: 'Commercial Bank of Ethiopia',
      icon: Icons.account_balance,
      color: Color(0xFF003087),
    ),
    _PaymentMethod(
      id: 'awash',
      name: 'Awash Bank',
      subtitle: 'Awash mobile banking',
      icon: Icons.account_balance_wallet,
      color: Color(0xFFE30613),
    ),
    _PaymentMethod(
      id: 'dashen',
      name: 'Dashen Bank',
      subtitle: 'Amole digital wallet',
      icon: Icons.credit_card,
      color: Color(0xFF1B4F9B),
    ),
    _PaymentMethod(
      id: 'cash',
      name: 'Cash on Delivery',
      subtitle: 'Pay when you receive',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFF6B7280),
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPlacingOrder = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final address =
        '${_nameController.text}, ${_addressController.text}, ${_cityController.text} | Phone: ${_phoneController.text} | Payment: $_selectedPayment';

    try {
      await FirestoreService().placeOrder(
        uid: uid,
        cartItems: widget.cartItems,
        totalAmount: widget.totalAmount + 50,
        address: address,
      );

      if (context.mounted) {
        context.read<CartProvider>().clearCart();
        _showSuccessDialog();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showSuccessDialog() {
    final color = Theme.of(context).colorScheme;
    final paymentName = _paymentMethods
        .firstWhere((p) => p.id == _selectedPayment)
        .name;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Order Confirmed!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Your order has been placed.\nPayment via $paymentName.',
              textAlign: TextAlign.center,
              style: TextStyle(color: color.secondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop()
                    ..pop();
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title:
            Text('Checkout', style: Theme.of(context).textTheme.displaySmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: color.inversePrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── SHIPPING ADDRESS
              _sectionLabel('DELIVERY ADDRESS', color),
              const SizedBox(height: 16),
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _phoneController,
                label: 'Phone Number (e.g. 0911234567)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 10) return 'Enter valid Ethiopian phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _addressController,
                label: 'Street / Kebele / Woreda',
                icon: Icons.location_on_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _cityController,
                label: 'City (e.g. Addis Ababa, Bahir Dar)',
                icon: Icons.location_city_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),

              // ── PAYMENT METHOD
              _sectionLabel('PAYMENT METHOD', color),
              const SizedBox(height: 12),
              ..._paymentMethods.map((method) => _paymentTile(method, color)),

              const SizedBox(height: 32),

              // ── ORDER SUMMARY
              _sectionLabel('ORDER SUMMARY', color),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: color.tertiary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...widget.cartItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.title}',
                                  style: TextStyle(color: color.secondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'ETB ${item.totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: color.inversePrimary),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    Divider(color: color.tertiary, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal',
                            style: TextStyle(color: color.secondary)),
                        Text(
                            'ETB ${widget.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(color: color.inversePrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery fee',
                            style: TextStyle(color: color.secondary)),
                        Text('ETB 50',
                            style: TextStyle(color: color.inversePrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: color.tertiary, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: color.inversePrimary)),
                        Text(
                          'ETB ${(widget.totalAmount + 50).toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: color.inversePrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: color.surface,
          border: Border(top: BorderSide(color: color.tertiary, width: 0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            child: _isPlacingOrder
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Place Order — ETB ${(widget.totalAmount + 50).toStringAsFixed(0)}'),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, ColorScheme color) {
    return Text(
      label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color.secondary,
          letterSpacing: 1.5),
    );
  }

  Widget _paymentTile(_PaymentMethod method, ColorScheme color) {
    final isSelected = _selectedPayment == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = method.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color.inversePrimary : color.tertiary,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.inversePrimary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(method.icon, color: method.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: color.inversePrimary,
                          fontSize: 14)),
                  Text(method.subtitle,
                      style:
                          TextStyle(color: color.secondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color.inversePrimary : color.tertiary,
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected ? color.inversePrimary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 12, color: color.surface)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
