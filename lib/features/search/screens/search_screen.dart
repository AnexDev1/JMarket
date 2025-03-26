// lib/features/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/search_category.dart';
import '../models/search_product.dart';
import '../models/trending_search.dart';
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

  // Enhanced product data for better display
  final List<Map<String, dynamic>> _dummyProducts = [
    {
      'id': '1',
      'name': 'Premium Wireless Headphones',
      'description': 'High-quality sound with noise cancellation',
      'price': 89.99,
      'rating': 4.5,
      'reviews': 128,
      'image': 'https://picsum.photos/id/3/400/400',
      'color': Colors.indigo.shade700
    },
    {
      'id': '2',
      'name': 'Smart Watch Series 5',
      'description': 'Track your fitness and stay connected',
      'price': 199.99,
      'rating': 4.2,
      'reviews': 94,
      'image': 'https://picsum.photos/id/26/400/400',
      'color': Colors.teal.shade700
    },
    // Additional products...
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

  void _performSearch(String query) {
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

    // Simulate search with delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      final results = _dummyProducts
          .where((product) =>
              product['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              product['description']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .map((data) => SearchProduct.fromMap(data))
          .toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;

        if (query.isNotEmpty &&
            !_recentSearches.contains(query) &&
            results.isNotEmpty) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }
      });

      _animationController.reset();
      _animationController.forward();
    });
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
              _performSearch(category);
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
