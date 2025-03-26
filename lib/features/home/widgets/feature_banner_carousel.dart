import 'package:flutter/material.dart';

class FeatureBannerCarousel extends StatefulWidget {
  const FeatureBannerCarousel({super.key});

  @override
  State<FeatureBannerCarousel> createState() => _FeatureBannerCarouselState();
}

class _FeatureBannerCarouselState extends State<FeatureBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Summer Sale',
      'subtitle': 'Up to 50% off on selected items',
      'tag': 'LIMITED OFFER',
      'colors': [Colors.indigo.shade400, Colors.indigo.shade800],
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Check out our latest collection',
      'tag': 'JUST IN',
      'colors': [Colors.teal.shade400, Colors.teal.shade800],
      'icon': Icons.local_shipping_outlined,
    },
    {
      'title': 'Flash Deals',
      'subtitle': '24-hour deals on top products',
      'tag': 'TODAY ONLY',
      'colors': [Colors.amber.shade400, Colors.deepOrange.shade600],
      'icon': Icons.flash_on_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Auto-slide functionality
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _startAutoSlide();
      }
    });
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Increased height to prevent overflow
    return SizedBox(
      height: 200, // Increased from 180 to provide more space
      child: Stack(
        children: [
          // Banner Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _buildBanner(banner, index);
            },
          ),

          // Indicators
          Positioned(
            bottom: 15,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _banners.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(Map<String, dynamic> banner, int index) {
    return Container(
      // Removed bottom margin and using proper padding instead
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: banner['colors'],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: banner['colors'][0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Using clipBehavior to ensure nothing overflows
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand, // Ensure stack fills the container
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              banner['icon'],
              size: 140,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            // Reduced bottom padding to give more space
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use min size to avoid expansion
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    banner['tag'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Reduced spacing
                Text(
                  banner['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 6), // Reduced spacing
                Text(
                  banner['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14), // Reduced spacing
                InkWell(
                  onTap: () {
                    // Shop now action
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Shop Now',
                      style: TextStyle(
                        color: banner['colors'][1],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
