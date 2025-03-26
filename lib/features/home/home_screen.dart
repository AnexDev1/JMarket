// File: lib/features/home/home_screen.dart
// Language: dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/datasources/remote/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _futureProducts;
  final List<String> _categories = [
    'All',
    'Electronics',
    'Gadgets',
    'Clothing',
    'Home',
    'Sports',
    'Books'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _futureProducts = _fetchProducts(_categories[0]);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _futureProducts = _fetchProducts(_categories[_tabController.index]);
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchProducts(String category) {
    return SupabaseService().fetchProducts(category: category);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildProductCardFromData(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        context.go('/product-details/${product['id']}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                width: double.infinity,
                child: Center(
                  child: product['image_urls'] != null &&
                          (product['image_urls'] as List).isNotEmpty
                      ? Image.network(
                          product['image_urls'][0],
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.gray500,
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'No Name',
                      style: TextStyles.body1
                          .copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['category'] ?? 'Unknown',
                      style: TextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const Spacer(),
                    Text(
                      '\$${product['price']}',
                      style: TextStyles.body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  hintText: 'Search products...',
                  leading: const Icon(Icons.search),
                  elevation: WidgetStateProperty.all(0),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                  onTap: () {},
                ),
              ),
            ),
            // Promo Carousel
            SliverToBoxAdapter(
              child: Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Featured Promotions',
                    style: TextStyles.heading4,
                  ),
                ),
              ),
            ),
            // Categories Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: TextStyles.heading5),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),
            // Categories Tab Bar
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                indicator: BoxDecoration(
                  color: AppColors.primaryBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: AppColors.primaryWhite,
                unselectedLabelColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                tabs: _categories
                    .map((category) => Tab(
                          height: 36,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(category),
                          ),
                        ))
                    .toList(),
              ),
            ),
            // Products Grid using FutureBuilder
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                        child: Text('Error: ${snapshot.error}',
                            style: TextStyles.body1)),
                  );
                } else if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildProductCardFromData(products[index]);
                        },
                        childCount: products.length,
                      ),
                    ),
                  );
                } else {
                  return const SliverToBoxAdapter(
                      child: Center(child: Text('No products found.')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
