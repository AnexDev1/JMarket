import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/search_category.dart';
import '../models/search_product.dart';
import '../models/trending_search.dart';
import '../services/product_service.dart';
import '../widgets/recent_searches_list.dart';
import '../widgets/search_categories_grid.dart';
import '../widgets/search_header.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/search_results_grid.dart';
import '../widgets/trending_searches.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Initialize product service
  final ProductService _productService = ProductService();

  // Recent searches
  final List<String> _recentSearches = [
    'Wireless headphones',
    'Smart watch',
    'Phone case',
    'Laptop sleeve',
  ];

  late List<SearchProduct> _searchResults = [];

  // Popular categories
  final List<SearchCategory> _popularCategories = [
    SearchCategory(
      name: 'Electronics',
      icon: Icons.devices_outlined,
      color: Colors.blue.shade700,
    ),
    SearchCategory(
      name: 'Clothing',
      icon: Icons.shopping_bag_outlined,
      color: Colors.green.shade600,
    ),
    SearchCategory(
      name: 'Home Goods',
      icon: Icons.chair_outlined,
      color: Colors.amber.shade700,
    ),
    SearchCategory(
      name: 'Books',
      icon: Icons.menu_book_outlined,
      color: Colors.red.shade700,
    ),
    SearchCategory(
      name: 'Sports',
      icon: Icons.sports_basketball_outlined,
      color: Colors.orange.shade700,
    ),
    SearchCategory(
      name: 'Beauty',
      icon: Icons.face_outlined,
      color: Colors.purple.shade600,
    ),
  ];

  // Trending searches
  final List<TrendingSearch> _trendingSearches = [
    TrendingSearch(term: 'Headphones', count: 1245),
    TrendingSearch(term: 'Smart Watch', count: 890),
    TrendingSearch(term: 'Laptop', count: 750),
    TrendingSearch(term: 'Phone', count: 1320),
    TrendingSearch(term: 'Camera', count: 430),
    TrendingSearch(term: 'Gaming', count: 980),
    TrendingSearch(term: 'Outdoor', count: 655),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      if (_searchQuery.isEmpty) {
        _searchResults.clear();
        _isSearching = false;
      }
    });
  }

  Future<void> _performSearch(String query, {bool isCategory = false}) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      FocusScope.of(context).unfocus();
    });

    try {
      print(
          'Performing ${isCategory ? "category" : "regular"} search for: $query');

      final results = isCategory
          ? await _productService.getProductsByCategory(query)
          : await _productService.searchProducts(query);

      print('Raw results type: ${results.runtimeType}');

      List<SearchProduct> products = [];

      if (isCategory) {
        // Process category search results
        for (var i = 0; i < results.length; i++) {
          try {
            final item = results[i];
            print('Processing item $i, type: ${item.runtimeType}');

            // Convert to Map<String, dynamic>
            Map<String, dynamic> product;
            if (item is Map<String, dynamic>) {
              product = item;
            } else if (item is Map) {
              product = Map<String, dynamic>.from(item);
            } else {
              print('Skipping item $i: not a valid map structure');
              continue;
            }

            // Extract the first image URL from the array
            String imageUrl = '';
            if (product.containsKey('image_urls') &&
                product['image_urls'] != null) {
              var imageUrls = product['image_urls'];
              print('Image URLs before processing: $imageUrls');

              if (imageUrls is List && imageUrls.isNotEmpty) {
                imageUrl = imageUrls[0].toString();
              } else if (imageUrls is String) {
                imageUrl = imageUrls;
              }
            }

            print('Product map: $product');

            products.add(SearchProduct(
              id: product['id']?.toString() ?? '',
              name: product['name'] ?? '',
              description: product['description'] ?? '',
              price: (product['price'] is int)
                  ? (product['price'] as int).toDouble()
                  : (product['price'] ?? 0.0).toDouble(),
              rating: (product['rating'] is int)
                  ? (product['rating'] as int).toDouble()
                  : (product['rating'] ?? 0.0).toDouble(),
              reviews: product['reviews'] ?? 0,
              imageUrl: imageUrl,
              color: Colors.black87,
              keyFeatures: product['key_features'] != null
                  ? List<String>.from(product['key_features'])
                  : [],
            ));
          } catch (e) {
            print('Error processing item $i: $e');
          }
        }
      } else {
        // For regular search results
        for (var i = 0; i < results.length; i++) {
          try {
            final item = results[i];

            // If already a SearchProduct, add directly
            if (item is SearchProduct) {
              products.add(item);
            }
            // If a map, convert to SearchProduct
            else if (item is Map) {
              final product = Map<String, dynamic>.from(item);
              products.add(SearchProduct.fromJson(product));
            }
          } catch (e) {
            print('Error processing regular search item: $e');
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _searchResults = products;
        _searchQuery = query;
        _isSearching = false;

        if (!isCategory && !_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 10) {
            _recentSearches.removeLast();
          }
          _saveRecentSearches();
        }
      });

      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      print('Search error: $e');
    }
  }

// Add this missing method
  void _saveRecentSearches() {
    // You can implement persistence here if needed
    // e.g., using SharedPreferences
    print('Saving recent searches: $_recentSearches');
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
      _searchResults.clear();
      _searchFocusNode.requestFocus();
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _clearAllRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              controller: _searchController,
              focusNode: _searchFocusNode,
              searchQuery: _searchQuery,
              onSubmitted: _performSearch,
              onClearSearch: _clearSearch,
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildInitialContent()
                  : _isSearching
                      ? SearchLoadingIndicator(searchQuery: _searchQuery)
                      : SearchResultsGrid(
                          results: _searchResults,
                          searchQuery: _searchQuery,
                          onClearSearch: _clearSearch,
                          animation: _fadeAnimation,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecentSearchesList(
            searches: _recentSearches,
            onSearchSelected: (search) {
              _searchController.text = search;
              _performSearch(search);
            },
            onSearchRemoved: _removeRecentSearch,
            onClearAll: _clearAllRecentSearches,
          ),
          if (_recentSearches.isNotEmpty)
            Divider(
              height: 32,
              thickness: 1,
              color: Colors.grey.shade100,
              indent: 16,
              endIndent: 16,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              'Popular Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          SearchCategoriesGrid(
            categories: _popularCategories,
            onCategorySelected: (category) {
              _searchController.text = category;
              _performSearch(category, isCategory: true);
            },
          ),
          const SizedBox(height: 24),
          TrendingSearches(
            searches: _trendingSearches,
            onSearchSelected: (search) {
              _searchController.text = search;
              _performSearch(search);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
