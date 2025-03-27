import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jmarket/features/home/widgets/feature_banner_carousel.dart';
import 'package:jmarket/features/home/widgets/home_categories_tab.dart';
import 'package:jmarket/features/home/widgets/home_products_grid.dart';
import 'package:provider/provider.dart';

import '../../core/theme/text_styles.dart';
import '../../data/datasources/remote/supabase_service.dart';
import '../../providers/search_provider.dart';
import '../product/product_details_screen.dart';
import 'widgets/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Define primary color to replace AppColors.primary
  final Color primaryColor = Colors.indigo.shade700;

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

  final ScrollController _scrollController = ScrollController();

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

  Future<List<Map<String, dynamic>>> _fetchProducts(String category) async {
    final products = await SupabaseService().fetchProducts(category: category);
    if (category.toLowerCase() == 'all') {
      products.shuffle();
    }
    return products;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final hasSearchQuery = searchProvider.searchQuery.isNotEmpty;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Elevated Search Bar
              SliverPersistentHeader(
                floating: true,
                delegate: _SliverAppBarDelegate(
                  child: Container(
                    color: Colors.grey[50],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const HomeSearchBar(),
                  ),
                ),
              ),

              // Show either search results or regular content
              if (hasSearchQuery) ...[
                // Search Results Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      localizations
                          .searchResultsFor(searchProvider.searchQuery),
                      style: TextStyles.heading5
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Search Results
                searchProvider.isLoading
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : searchProvider.searchResults.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 74, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(localizations.noProductsFound,
                                      style: TextStyles.body1.copyWith(
                                        color: Colors.grey.shade600,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(localizations.tryDifferentSearchTerm,
                                      style: TextStyles.caption.copyWith(
                                        color: Colors.grey.shade500,
                                      )),
                                ],
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product =
                                      searchProvider.searchResults[index];
                                  return _buildProductCard(context, product);
                                },
                                childCount: searchProvider.searchResults.length,
                              ),
                            ),
                          ),
              ] else ...[
                // Featured Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: FeatureBannerCarousel(),
                  ),
                ),

                // Categories Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.categories,
                          style: TextStyles.heading5.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Row(
                            children: [
                              Text(localizations.viewAll),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Categories Tab
                SliverToBoxAdapter(
                  child: HomeCategoriesTab(
                    tabController: _tabController,
                    categories: _categories,
                  ),
                ),

                // Products Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text(
                      localizations.popularProducts,
                      style: TextStyles.heading5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Products Grid
                HomeProductsGrid(futureProducts: _futureProducts),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final bool hasDiscount =
        product['discount'] != null && product['discount'] > 0;
    final localizations = AppLocalizations.of(context)!;

    return Hero(
      tag: 'product-${product['id']}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(
                  productId: product['id'].toString(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Stack(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: product['image_urls'] != null &&
                                (product['image_urls'] as List).isNotEmpty
                            ? Image.network(
                                product['image_urls'][0],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image),
                              )
                            : const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                      ),
                    ),
                    if (hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            localizations.discountPercent(product['discount']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Product details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? localizations.unknownProduct,
                          style: TextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '\$${product['price']}',
                              style: TextStyles.body2.copyWith(
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                '\$${(product['price'] * (1 + product['discount'] / 100)).toStringAsFixed(2)}',
                                style: TextStyles.caption.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product['rating'] ?? 0}',
                              style: TextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 18,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverAppBarDelegate({
    required this.child,
    this.height = 60.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
