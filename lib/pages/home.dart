import 'package:ecommerce/components/bottom_tabs.dart';
import 'package:ecommerce/components/product_card.dart';
import 'package:ecommerce/components/promo_carousel.dart';
import 'package:ecommerce/models/product_model.dart';
import 'package:ecommerce/pages/cart.dart';
import 'package:ecommerce/pages/categories.dart';
import 'package:ecommerce/pages/orders.dart';
import 'package:ecommerce/pages/profile.dart';
import 'package:ecommerce/pages/wishlist.dart';
import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/providers/wishlist_provider.dart';
import 'package:ecommerce/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/category_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().startListening();
    context.read<WishlistProvider>().startListening();
    _firestoreService.seedProductsIfEmpty();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _searchQuery = '';
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });
    final results = await _firestoreService.searchProducts(query);
    setState(() => _searchResults = results);
  }

  String getName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Guest';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: color.surface,
      bottomNavigationBar: BottomTabs(
        selectedIndex: _bottomNavIndex,
        onTabChange: (index) => setState(() => _bottomNavIndex = index),
      ),
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Discover',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              'Good morning, ${getName()}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: color.secondary,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                icon: Icon(Icons.shopping_bag_outlined, color: color.inversePrimary, size: 26),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: color.surface, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '$cartCount',
                      style: TextStyle(color: color.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildHomeTab(color),
          const CategoriesPage(),
          const WishlistPage(),
          const OrdersPage(),
          const ProfilePage(),
        ],
      ),
    );
  }

  Widget _buildHomeTab(ColorScheme color) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search for clothes, shoes, electronics...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.search, color: color.secondary, size: 22),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: color.secondary),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          if (_isSearching) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_searchResults.length} results for "$_searchQuery"',
                style: TextStyle(fontWeight: FontWeight.w600, color: color.inversePrimary),
              ),
            ),
            const SizedBox(height: 16),
            if (_searchResults.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: color.tertiary),
                      const SizedBox(height: 16),
                      Text('No items found', style: TextStyle(color: color.secondary)),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) => ProductCard(product: _searchResults[i]),
              ),
            const SizedBox(height: 40),
          ] else ...[
            // ── Promo Carousel
            const PromoCarousel(),

            // ── Categories
            const SizedBox(height: 32),
            _sectionHeader('Shop by Category', 'View all', color, onTap: () => setState(() => _bottomNavIndex = 1)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  CategoryCard(title: 'Fashion', icon: Icons.checkroom),
                  SizedBox(width: 16),
                  CategoryCard(title: 'Electronics', icon: Icons.phone_iphone),
                  SizedBox(width: 16),
                  CategoryCard(title: 'Home', icon: Icons.chair_outlined),
                  SizedBox(width: 16),
                  CategoryCard(title: 'Beauty', icon: Icons.face_retouching_natural),
                  SizedBox(width: 16),
                  CategoryCard(title: 'Sports', icon: Icons.sports_soccer),
                ],
              ),
            ),

            // ── Featured Products
            const SizedBox(height: 32),
            _sectionHeader('Featured', '', color),
            const SizedBox(height: 16),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getFeaturedProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return _loadingRow(color);
                final products = snap.data ?? [];
                if (products.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => ProductCard(product: products[i]),
                  ),
                );
              },
            ),

            // ── All Products
            const SizedBox(height: 32),
            _sectionHeader('New Arrivals', '', color),
            const SizedBox(height: 16),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final products = snap.data ?? [];
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => ProductCard(product: products[i]),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, ColorScheme color, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: TextStyle(color: color.secondary, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _loadingRow(ColorScheme color) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: 160,
          decoration: BoxDecoration(color: color.tertiary.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
