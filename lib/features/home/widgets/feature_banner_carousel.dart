// dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../widgets/skeleton_banner.dart';

class FeatureBannerCarousel extends StatefulWidget {
  const FeatureBannerCarousel({Key? key}) : super(key: key);

  @override
  State<FeatureBannerCarousel> createState() => _FeatureBannerCarouselState();
}

class _FeatureBannerCarouselState extends State<FeatureBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = true; // Added loading state flag

  @override
  void initState() {
    super.initState();
    _fetchBanners();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _startAutoSlide();
      }
    });
  }

  Future<void> _fetchBanners() async {
    try {
      final storage = Supabase.instance.client.storage;
      final files = await storage.from('jmarket').list(
            path: 'features',
          );

      files.sort((a, b) {
        final aCreated = a.createdAt ?? '';
        final bCreated = b.createdAt ?? '';
        return bCreated.compareTo(aCreated);
      });

      final latestFiles = files.take(3).toList();

      final banners = latestFiles.map((file) {
        final fileName = file.name;
        final filePath = 'features/$fileName';
        final imageUrl = storage.from('jmarket').getPublicUrl(filePath);
        return {
          'image_url': imageUrl,
          'icon': Icons.shopping_bag_outlined,
        };
      }).toList();

      setState(() {
        _banners = banners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally log the error
    }
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _banners.isNotEmpty) {
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
    if (_isLoading) {
      // Show a skeleton loader while waiting
      return SizedBox(
        height: 200,
        child: const SkeletonBanner(height: 200),
      );
    } else if (_banners.isEmpty) {
      // Display a custom empty state if no banners found
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No banners available",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: banner['image_url'],
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => const SkeletonBanner(height: 200),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        ),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
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
            ],
          ),
        ),
      ),
    );
  }
}
