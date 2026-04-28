import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  int currentIndex = 0;

  Widget _buildCarouselItem({
    required String title,
    required String headline,
    required String subtitle,
    required List<Color> colors,
    required Widget imageWidget,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Shop Now",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: imageWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        // Item 1 (Original)
        _buildCarouselItem(
          title: "Special Offer",
          headline: "Up to 50% OFF",
          subtitle: "On selected items",
          colors: const [Color(0xFF6A5AE0), Color(0xFF8A5CFF)],
          imageWidget: Image.asset(
            "lib/assets/bag.png",
            width: 120,
            fit: BoxFit.contain,
          ),
        ),
        // Item 2
        _buildCarouselItem(
          title: "New Arrivals",
          headline: "Smart Watches",
          subtitle: "Starting from \$89",
          colors: const [Color(0xFFFE7474), Color(0xFFFF9B9B)],
          imageWidget: const Icon(
            Icons.watch,
            size: 100,
            color: Colors.white,
          ),
        ),
        // Item 3
        _buildCarouselItem(
          title: "Weekend Sale",
          headline: "Audio Gear",
          subtitle: "Get extra 20% OFF",
          colors: const [Color(0xFF38B29C), Color(0xFF55E3CB)],
          imageWidget: const Icon(
            Icons.headphones,
            size: 100,
            color: Colors.white,
          ),
        ),
      ],
      options: CarouselOptions(
        height: 180,
        viewportFraction: 1,
        onPageChanged: (index, reason) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
