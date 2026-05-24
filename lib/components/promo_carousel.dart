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
    required BuildContext context,
    required String title,
    required String headline,
    required String subtitle,
    required Color bgColor,
    required Widget imageWidget,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Shop Now",
                      style: TextStyle(
                        color: bgColor,
                        fontSize: 12,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: [
            _buildCarouselItem(
              context: context,
              title: "Special Offer",
              headline: "Up to 50% OFF",
              subtitle: "On selected items",
              bgColor: const Color(0xFF111827), // Deep black
              imageWidget: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
            ),
            _buildCarouselItem(
              context: context,
              title: "New Arrivals",
              headline: "Smart\nWatches",
              subtitle: "Starting from ETB 4,999",
              bgColor: const Color(0xFF4B5563), // Slate gray
              imageWidget: Icon(Icons.watch_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
            ),
            _buildCarouselItem(
              context: context,
              title: "Weekend Sale",
              headline: "Premium\nAudio",
              subtitle: "Get extra 20% OFF",
              bgColor: const Color(0xFF374151), // Dark gray
              imageWidget: Icon(Icons.headphones_outlined, size: 80, color: Colors.white.withOpacity(0.9)),
            ),
          ],
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.95,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() => currentIndex = index);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Custom sleek dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              width: currentIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: currentIndex == index 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
