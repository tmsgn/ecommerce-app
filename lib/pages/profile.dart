import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final cartCount = context.watch<CartProvider>().itemCount;
    final wishlistCount = context.watch<WishlistProvider>().itemCount;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final name = user?.displayName ?? 'Guest User';
        final email = user?.email ?? 'No email linked';
        final photoURL = user?.photoURL;

        return Scaffold(
          backgroundColor: color.surface,
          appBar: AppBar(
            title: Text('Profile', style: Theme.of(context).textTheme.displaySmall),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar + Name Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: color.tertiary,
                      backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                      child: photoURL == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'G',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: color.inversePrimary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(email, style: TextStyle(color: color.secondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    // Edit profile button
                    OutlinedButton(
                      onPressed: () => _showEditProfileSheet(context, user),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color.inversePrimary,
                        side: BorderSide(color: color.tertiary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Quick Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: color.tertiary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _statItem(context, '$cartCount', 'In Cart', Icons.shopping_bag_outlined, color),
                      _divider(color),
                      _statItem(context, '$wishlistCount', 'Wishlist', Icons.favorite_border, color),
                      _divider(color),
                      _orderCountStat(context, user?.uid ?? '', color),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Account Section
                _sectionLabel('ACCOUNT', color),
                const SizedBox(height: 12),
                _menuItem(
                  context,
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () => _showEditProfileSheet(context, user),
                  color: color,
                ),
                _menuItem(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'Shipping Addresses',
                  onTap: () => _showAddressSheet(context, color),
                  color: color,
                ),
                _menuItem(
                  context,
                  icon: Icons.payment_outlined,
                  label: 'Payment Methods',
                  onTap: () => _showPaymentSheet(context, color),
                  color: color,
                ),

                const SizedBox(height: 24),

                // ── Preferences Section
                _sectionLabel('PREFERENCES', color),
                const SizedBox(height: 12),
                _themeToggleTile(context, color),
                _menuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: color.inversePrimary,
                  ),
                  onTap: null,
                  color: color,
                ),

                const SizedBox(height: 24),

                // ── Support Section
                _sectionLabel('SUPPORT', color),
                const SizedBox(height: 12),
                _menuItem(
                  context,
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () => _showHelpSheet(context, color),
                  color: color,
                ),
                _menuItem(
                  context,
                  icon: Icons.info_outline,
                  label: 'About App',
                  onTap: () => _showAboutDialog(context, color),
                  color: color,
                ),

                const SizedBox(height: 32),

                // ── Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label, ColorScheme color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color.secondary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label, IconData icon, ColorScheme color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: color.secondary),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.inversePrimary)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color.secondary)),
        ],
      ),
    );
  }

  Widget _orderCountStat(BuildContext context, String uid, ColorScheme color) {
    return Expanded(
      child: StreamBuilder(
        stream: FirestoreService().getOrders(uid),
        builder: (context, snap) {
          final count = snap.data?.length ?? 0;
          return Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 22, color: color.secondary),
              const SizedBox(height: 8),
              Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.inversePrimary)),
              const SizedBox(height: 4),
              Text('Orders', style: TextStyle(fontSize: 12, color: color.secondary)),
            ],
          );
        },
      ),
    );
  }

  Widget _divider(ColorScheme color) {
    return Container(width: 1, height: 48, color: color.tertiary);
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme color,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        leading: Icon(icon, color: color.inversePrimary, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color.inversePrimary,
            fontSize: 15,
          ),
        ),
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios, size: 14, color: color.secondary),
        onTap: onTap,
      ),
    );
  }

  Widget _themeToggleTile(BuildContext context, ColorScheme color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, child) {
          final switchValue = currentMode == ThemeMode.system ? isDarkMode : currentMode == ThemeMode.dark;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            leading: Icon(
              switchValue ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: color.inversePrimary,
              size: 22,
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w500, color: color.inversePrimary, fontSize: 15),
            ),
            trailing: Switch(
              value: switchValue,
              onChanged: (value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
              activeColor: color.inversePrimary,
            ),
          );
        },
      ),
    );
  }

  // ── Bottom Sheets & Dialogs ────────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context, User? user) {
    final nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final color = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: color.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: Icon(Icons.close, color: color.secondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Display Name'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: user?.email ?? '',
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    await user?.updateDisplayName(nameCtrl.text.trim());
                    await user?.reload();
                    await FirestoreService().createUserProfile(
                      uid: user?.uid ?? '',
                      name: nameCtrl.text.trim(),
                      email: user?.email ?? '',
                    );
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context, ColorScheme color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping Addresses', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: Icon(Icons.close, color: color.secondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            _addressTile('Home', '123 Main Street, New York, NY 10001', true, color),
            const SizedBox(height: 12),
            _addressTile('Work', '456 Office Park, San Francisco, CA 94102', false, color),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Address'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.inversePrimary,
                  side: BorderSide(color: color.tertiary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressTile(String label, String address, bool isDefault, ColorScheme color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: isDefault ? color.inversePrimary : color.tertiary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, size: 20, color: color.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.inversePrimary, borderRadius: BorderRadius.circular(4)),
                        child: Text('DEFAULT', style: TextStyle(color: color.onPrimary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: TextStyle(color: color.secondary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, ColorScheme color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Methods', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: Icon(Icons.close, color: color.secondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            _paymentTile('Visa', '**** **** **** 4242', Icons.credit_card, color),
            const SizedBox(height: 12),
            _paymentTile('PayPal', 'user@email.com', Icons.account_balance_wallet_outlined, color),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Payment Method'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.inversePrimary,
                  side: BorderSide(color: color.tertiary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(String name, String detail, IconData icon, ColorScheme color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.tertiary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary)),
                const SizedBox(height: 2),
                Text(detail, style: TextStyle(color: color.secondary, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: color.secondary),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context, ColorScheme color) {
    final items = [
      {'q': 'How do I track my order?', 'a': 'Go to the Orders tab to view real-time status of all your purchases.'},
      {'q': 'Can I cancel an order?', 'a': 'Orders can be cancelled within 1 hour of placement. Contact support for help.'},
      {'q': 'What is the return policy?', 'a': 'We accept returns within 30 days of delivery for most items in original condition.'},
      {'q': 'How do I contact support?', 'a': 'Email us at support@shopease.com or use live chat on our website.'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Help & Support', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: Icon(Icons.close, color: color.secondary), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 24),
            ...items.map((item) => _faqTile(item['q']!, item['a']!, color)),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer, ColorScheme color) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Text(question, style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary, fontSize: 14)),
          iconColor: color.secondary,
          collapsedIconColor: color.secondary,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: TextStyle(color: color.secondary, height: 1.5, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, ColorScheme color) {
    const members = [
      ('BDU1602534', 'Temesgen', 'Tarekegn'),
      ('BDU1602667', 'Wintana', 'Girma'),
      ('BDU1602708', 'Yalemzewud', 'Tenaw'),
      ('BDU1602761', 'Yetmwork', 'Lakachew'),
      ('BDU1602875', 'Yordanos', 'Tsehay'),
      ('BDU1602881', 'Yosef', 'Tadesse'),
      ('BDU1602880', 'Yosef', 'Melaku'),
      ('BDU1602906', 'Zelalem', 'Ybabe'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: color.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: color.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // App icon + name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF09090B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text('SHOPEASE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: color.inversePrimary,
                      )),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0',
                      style: TextStyle(color: color.secondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'A premium e-commerce app built with Flutter & Firebase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: color.secondary, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Project info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.tertiary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PROJECT INFO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color.secondary,
                        letterSpacing: 1.5,
                      )),
                  const SizedBox(height: 10),
                  _infoRow('Institution', 'Bahir Dar University', color),
                  _infoRow('Department', 'Computer Science', color),
                  _infoRow('Course', 'Mobile App Development', color),
                  _infoRow('Group', 'Group 7', color),
                  _infoRow('Platform', 'Flutter + Firebase', color),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Group members
            Text('GROUP MEMBERS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color.secondary,
                  letterSpacing: 1.5,
                )),
            const SizedBox(height: 12),
            ...members.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: color.tertiary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.inversePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                              color: color.onPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${m.$2} ${m.$3}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: color.inversePrimary,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 2),
                          Text(m.$1,
                              style: TextStyle(
                                color: color.secondary,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                  color: color.secondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                  color: color.inversePrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: color.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary)),
        content: Text('Are you sure you want to sign out of your account?', style: TextStyle(color: color.secondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: color.secondary),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
