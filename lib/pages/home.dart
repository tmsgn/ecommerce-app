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
    // Start listening to cart and wishlist
    context.read<CartProvider>().startListening();
    context.read<WishlistProvider>().startListening();
    // Seed products — runs after auth is confirmed, so permission rules pass
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
    setState(() {
      _searchResults = results;
    });
  }

  String getName() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Guest';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      extendBody: true,
      backgroundColor: color.surface,
      bottomNavigationBar: BottomTabs(
        selectedIndex: _bottomNavIndex,
        onTabChange: (index) => setState(() => _bottomNavIndex = index),
      ),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.primary, color.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    getName().substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Hello, ${getName()} 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color.inversePrimary)),
                    Text('What are you shopping for today?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: color.inversePrimary.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_outlined, color: color.inversePrimary),
          ),
          // Cart with badge
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                icon: Icon(Icons.shopping_bag_outlined, color: color.inversePrimary),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: color.secondary, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildHomeTab(color, isDark),
          const CategoriesPage(),
          const WishlistPage(),
          const OrdersPage(),
          const ProfilePage(),
        ],
      ),
    );
  }

  Widget _buildHomeTab(ColorScheme color, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: color.inversePrimary.withOpacity(0.4), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: color.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: color.inversePrimary.withOpacity(0.5)),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Search Results
          if (_isSearching) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_searchResults.length} results for "$_searchQuery"',
                style: TextStyle(fontWeight: FontWeight.bold, color: color.inversePrimary),
              ),
            ),
            const SizedBox(height: 12),
            if (_searchResults.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 60, color: color.primary.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('No products found', style: TextStyle(color: color.inversePrimary.withOpacity(0.5))),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _searchResults.length,
                  itemBuilder: (ctx, i) => SizedBox(height: 240, child: ProductCard(product: _searchResults[i])),
                ),
              ),
          ] else ...[
            // ── Promo Carousel
            const SizedBox(height: 16),
            const PromoCarousel(),

            // ── Categories
            const SizedBox(height: 24),
            _sectionHeader('Shop by Category', 'See all', color, onTap: () => setState(() => _bottomNavIndex = 1)),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CategoryCard(title: 'Fashion', icon: Icons.checkroom, backgroundColor: const Color(0xFFFFE0EC)),
                  const SizedBox(width: 12),
                  CategoryCard(title: 'Electronics', icon: Icons.phone_iphone, backgroundColor: const Color(0xFFFFEDD8)),
                  const SizedBox(width: 12),
                  CategoryCard(title: 'Home & Living', icon: Icons.chair, backgroundColor: const Color(0xFFD8F5E9)),
                  const SizedBox(width: 12),
                  CategoryCard(title: 'Beauty', icon: Icons.face_retouching_natural, backgroundColor: const Color(0xFFEDE0FF)),
                  const SizedBox(width: 12),
                  CategoryCard(title: 'Sports', icon: Icons.sports_soccer, backgroundColor: const Color(0xFFD8EEFF)),
                  const SizedBox(width: 12),
                  CategoryCard(title: 'Toys', icon: Icons.toys, backgroundColor: const Color(0xFFFFF9C4)),
                ],
              ),
            ),

            // ── Featured Products
            const SizedBox(height: 28),
            _sectionHeader('✨ Featured', 'See all', color),
            const SizedBox(height: 12),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getFeaturedProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _loadingRow();
                }
                final products = snap.data ?? [];
                if (products.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => SizedBox(height: 240, child: ProductCard(product: products[i])),
                  ),
                );
              },
            ),

            // ── Best Sellers
            const SizedBox(height: 28),
            _sectionHeader('🔥 Best Sellers', 'See all', color),
            const SizedBox(height: 12),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getBestSellerProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _loadingRow();
                }
                final products = snap.data ?? [];
                if (products.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => SizedBox(height: 240, child: ProductCard(product: products[i])),
                  ),
                );
              },
            ),

            // ── All Products
            const SizedBox(height: 28),
            _sectionHeader('All Products', '', color),
            const SizedBox(height: 12),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snap.data ?? [];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => ProductCard(product: products[i]),
                  ),
                );
              },
            ),
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
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color.inversePrimary)),
          if (action.isNotEmpty)
            GestureDetector(
              onTap: onTap,
              child: Text(action, style: TextStyle(color: color.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _loadingRow() {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
