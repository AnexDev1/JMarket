import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // Dummy data for recent searches and search results
  final List<String> _recentSearches = [
    'Wireless headphones',
    'Smart watch',
    'Phone case',
    'Laptop sleeve',
  ];

  late List<Map<String, dynamic>> _searchResults = [];

  // Dummy categories
  final List<Map<String, dynamic>> _popularCategories = [
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Clothing', 'icon': Icons.shopping_bag},
    {'name': 'Home Goods', 'icon': Icons.chair},
    {'name': 'Books', 'icon': Icons.book},
    {'name': 'Sports', 'icon': Icons.sports_basketball},
    {'name': 'Beauty', 'icon': Icons.face},
  ];

  // Dummy products for results
  final List<Map<String, dynamic>> _dummyProducts = [
    {
      'id': '1',
      'name': 'Wireless Headphones',
      'price': 89.99,
      'rating': 4.5,
      'image': 'headphones.jpg'
    },
    {
      'id': '2',
      'name': 'Smart Watch',
      'price': 199.99,
      'rating': 4.2,
      'image': 'watch.jpg'
    },
    {
      'id': '3',
      'name': 'Bluetooth Speaker',
      'price': 59.99,
      'rating': 4.0,
      'image': 'speaker.jpg'
    },
    {
      'id': '4',
      'name': 'Phone Case',
      'price': 19.99,
      'rating': 4.3,
      'image': 'case.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
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
      // Simulate search with delay
      Future.delayed(const Duration(milliseconds: 800), () {
        // Filter dummy products that match the query
        final results = _dummyProducts
            .where((product) => product['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

        setState(() {
          _searchResults = results;
          _isSearching = false;

          // Add to recent searches if not already there
          if (query.isNotEmpty && !_recentSearches.contains(query)) {
            _recentSearches.insert(0, query);
            if (_recentSearches.length > 5) {
              _recentSearches.removeLast();
            }
          }
        });
      });
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
      _searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildInitialContent()
                  : _isSearching
                      ? _buildLoadingIndicator()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _clearSearch();
              },
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style:
                        TextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style:
                          TextStyles.body2.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_recentSearches[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _recentSearches.removeAt(index);
                      });
                    },
                  ),
                  onTap: () {
                    _searchController.text = _recentSearches[index];
                    _performSearch(_recentSearches[index]);
                  },
                );
              },
            ),
            const Divider(height: 32),
          ],

          // Popular categories
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Popular Categories',
              style: TextStyles.body1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _popularCategories.length,
            itemBuilder: (context, index) {
              final category = _popularCategories[index];
              return GestureDetector(
                onTap: () {
                  _searchController.text = category['name'];
                  _performSearch(category['name']);
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category['icon'],
                        color: AppColors.gray700,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: TextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Trending searches
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Trending Searches',
              style: TextStyles.body1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Headphones',
                'Smart Watch',
                'Laptop',
                'Phone',
                'Camera',
                'Gaming',
                'Outdoor',
              ].map((tag) => _buildTrendingTag(tag)).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTrendingTag(String tag) {
    return GestureDetector(
      onTap: () {
        _searchController.text = tag;
        _performSearch(tag);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag,
          style: TextStyles.caption,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: TextStyles.body1.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyles.heading4,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyles.body1.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            '${_searchResults.length} results for "$_searchQuery"',
            style: TextStyles.body2.copyWith(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
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
                      // Product image
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.gray500,
                          ),
                        ),
                      ),
                      // Product details
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: TextStyles.body1
                                  .copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${product['price']}',
                              style: TextStyles.body2
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            // Rating
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product['rating']}',
                                  style: TextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
