import 'package:ecommerce/components/bottom_tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/category_card.dart';
import '../components/product_card.dart';
import '../components/promo_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0; // For the bottom navigation tabs

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  String getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? "No email";
  }

  String getName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? "No name";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomTabs(
        selectedIndex: _bottomNavIndex,
        onTabChange: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: Colors.purple[50],
                child: const FaIcon(
                  FontAwesomeIcons.solidUser,
                  size: 18,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Hello, ${getName()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "What are you shopping for today?",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                bottom:
                    100), // add padding so it's not hidden behind the floating nav
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search for products...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.purple, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const PromoCarousel(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "See all",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        CategoryCard(
                            title: "Fashion",
                            icon: Icons.checkroom,
                            backgroundColor: Colors.pink.shade100),
                        const SizedBox(width: 20),
                        CategoryCard(
                            title: "Electronics",
                            icon: Icons.phone_iphone,
                            backgroundColor: Colors.orange.shade100),
                        const SizedBox(width: 20),
                        CategoryCard(
                            title: "Home & Living",
                            icon: Icons.chair,
                            backgroundColor: Colors.green.shade100),
                        const SizedBox(width: 20),
                        CategoryCard(
                            title: "Beauty",
                            icon: Icons.face_retouching_natural,
                            backgroundColor: Colors.purple.shade100),
                        const SizedBox(width: 20),
                        CategoryCard(
                            title: "Sports",
                            icon: Icons.sports_soccer,
                            backgroundColor: Colors.blue.shade100),
                        const SizedBox(width: 20),
                        CategoryCard(
                            title: "Toys",
                            icon: Icons.toys,
                            backgroundColor: Colors.yellow.shade100),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Featured Products",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "See all",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: const [
                        ProductCard(
                            title: "Wireless Headphones",
                            price: 59.99,
                            rating: 4.5,
                            icon: Icons.headphones),
                        SizedBox(width: 16),
                        ProductCard(
                            title: "Smart Watch",
                            price: 89.99,
                            rating: 4.6,
                            icon: Icons.watch),
                        SizedBox(width: 16),
                        ProductCard(
                            title: "Sneakers",
                            price: 49.99,
                            rating: 4.4,
                            icon: Icons.do_not_step),
                        SizedBox(width: 16),
                        ProductCard(
                            title: "Backpack",
                            price: 39.99,
                            rating: 4.3,
                            icon: Icons.backpack),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Best Selling Products",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "See all",
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: const [
                          ProductCard(
                              title: "Leather Jacket",
                              price: 129.99,
                              rating: 4.7,
                              icon: Icons.checkroom),
                          SizedBox(width: 16),
                          ProductCard(
                              title: "Gaming Console",
                              price: 299.99,
                              rating: 4.8,
                              icon: Icons.videogame_asset),
                          SizedBox(width: 16),
                          ProductCard(
                              title: "Coffee Maker",
                              price: 79.99,
                              rating: 4.6,
                              icon: Icons.coffee),
                          SizedBox(width: 16),
                          ProductCard(
                              title: "Fitness Tracker",
                              price: 49.99,
                              rating: 4.5,
                              icon: Icons.fitness_center),
                        ]),
                  ),
                ],
              ),
            ),
          ),
          // Category Tab Placeholder
          const Center(child: Text("Categories Page")),
          // Wishlist Tab Placeholder
          const Center(child: Text("Wishlist Page")),
          // Orders Tab Placeholder
          const Center(child: Text("Orders Page")),
          // Profile Tab Placeholder
          const Center(child: Text("Profile Page")),
        ],
      ),
    );
  }
}
