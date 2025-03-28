// dart
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
      // 'title': 'Summer Sale',
      // 'subtitle': 'Up to 50% off on selected items',
      // 'tag': 'LIMITED OFFER',
      'image': 'assets/features.jpg',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      // 'title': 'New Arrivals',
      // 'subtitle': 'Check out our latest collection',
      // 'tag': 'JUST IN',
      'image': 'assets/features2.jpg',
      'icon': Icons.local_shipping_outlined,
    },
    {
      // 'title': 'Flash Deals',
      // 'subtitle': '24-hour deals on top products',
      // 'tag': 'TODAY ONLY',
      'image': 'assets/features3.jpg',
      'icon': Icons.flash_on_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();

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
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
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
              return _buildBanner(banner);
            },
          ),
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

  Widget _buildBanner(Map<String, dynamic> banner) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(banner['image']),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
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
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 12,
          //           vertical: 6,
          //         ),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: Text(
          //           banner['tag'],
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ),
          //       // const SizedBox(height: 10),
          //       // Text(
          //       //   banner['title'],
          //       //   style: const TextStyle(
          //       //     color: Colors.white,
          //       //     fontWeight: FontWeight.bold,
          //       //     fontSize: 28,
          //       //   ),
          //       // ),
          //       // const SizedBox(height: 6),
          //       // Text(
          //       //   banner['subtitle'],
          //       //   style: TextStyle(
          //       //     color: Colors.white.withOpacity(0.8),
          //       //     fontSize: 16,
          //       //   ),
          //       // ),
          //       // const SizedBox(height: 14),
          //       // InkWell(
          //       //   onTap: () {
          //       //     // Shop now action
          //       //   },
          //       //   child: Container(
          //       //     padding: const EdgeInsets.symmetric(
          //       //       horizontal: 16,
          //       //       vertical: 10,
          //       //     ),
          //       //     decoration: BoxDecoration(
          //       //       color: Colors.white,
          //       //       borderRadius: BorderRadius.circular(24),
          //       //     ),
          //       //     child: const Text(
          //       //       'Shop Now',
          //       //       style: TextStyle(
          //       //         color: Colors.black,
          //       //         fontWeight: FontWeight.bold,
          //       //       ),
          //       //     ),
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
