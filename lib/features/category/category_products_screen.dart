// dart
import 'package:flutter/material.dart';

import '../../services/product_service.dart';
import '../product/product_details_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _displayedProducts = [];
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _sortBy = 'popular';

  // Category defaults and properties
  late String _categoryName;
  late Color _categoryColor;
  late IconData _categoryIcon;

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeCategoryData();
    _loadProducts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          _hasMore &&
          !_isLoadingMore) {
        _loadMoreProducts();
      }
    });
  }

  void _initializeCategoryData() {
    _categoryName = 'Category';
    _categoryColor = Colors.blue;
    _categoryIcon = Icons.category;
    if (widget.category != null) {
      _categoryName = widget.category!['name'] ?? _categoryName;
      _categoryColor = widget.category!['color'] ?? _categoryColor;
      _categoryIcon = widget.category!['icon'] ?? _categoryIcon;
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products =
          await _productService.getProductsByCategory(_categoryName);

      // Sort products based on _sortBy option
      switch (_sortBy) {
        case 'newest':
          products.sort((a, b) {
            final aDate =
                DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
            final bDate =
                DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          break;
        case 'price_low':
          products
              .sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
          break;
        case 'price_high':
          products
              .sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
          break;
        case 'popular':
        default:
          break;
      }

      _allProducts = products;
      _applyFilterAndPagination();
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _allProducts = [];
        _displayedProducts = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
        );
      }
    }
  }

  void _applyFilterAndPagination() {
    // Reset pagination and apply search filter on _allProducts
    _currentPage = 1;
    List<Map<String, dynamic>> filtered =
        _filterProducts(_allProducts, _searchQuery);
    _displayedProducts = filtered.take(_pageSize).toList();
    _hasMore = filtered.length > _pageSize;
  }

  List<Map<String, dynamic>> _filterProducts(
      List<Map<String, dynamic>> products, String query) {
    if (query.isEmpty) return products;
    return products
        .where((product) => product['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  void _loadMoreProducts() {
    if (!_hasMore || _isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    List<Map<String, dynamic>> filtered =
        _filterProducts(_allProducts, _searchQuery);
    _currentPage++;
    final nextItems =
        filtered.skip((_currentPage - 1) * _pageSize).take(_pageSize).toList();
    setState(() {
      _displayedProducts.addAll(nextItems);
      _isLoadingMore = false;
      if (_displayedProducts.length >= filtered.length) {
        _hasMore = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      pinned: true,
      title: _isSearching
          ? TextField(
              autofocus: true,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilterAndPagination();
                });
              },
            )
          : Text(_categoryName),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _categoryColor,
                _categoryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  _categoryIcon,
                  size: 150,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        _isSearching
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                    _applyFilterAndPagination();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 50.0,
        maxHeight: 50.0,
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${_filterProducts(_allProducts, _searchQuery).length} products',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('Sort by:', style: TextStyle(color: Colors.grey[800])),
              const SizedBox(width: 8),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.white,
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  isDense: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  iconEnabledColor: Colors.grey[700],
                  items: const [
                    DropdownMenuItem(value: 'popular', child: Text('Popular')),
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(
                        value: 'price_low', child: Text('Price: Low to High')),
                    DropdownMenuItem(
                        value: 'price_high', child: Text('Price: High to Low')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                      _loadProducts();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// dart
  Widget _buildProductCard(Map<String, dynamic> product) {
    final String id = product['id'].toString();
    final name = product['name'] ?? 'Unknown Product';
    final price = product['price'] ?? 0;
    final rating = product['rating'] ?? 0;

    String imageUrl = 'https://via.placeholder.com/150';
    if (product['image_urls'] is List &&
        (product['image_urls'] as List).isNotEmpty) {
      imageUrl = product['image_urls'][0];
    }

    return Hero(
      tag: 'product-$id',
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(productId: id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$price ETB',
                        style: TextStyle(
                          color: _categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' $rating'),
                          const Spacer(),
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: _categoryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          if (!_isLoading) _buildFilterBar(),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _categoryColor),
                  ),
                )
              : _displayedProducts.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products in this category',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for new arrivals',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
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
                          childAspectRatio: 0.63,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < _displayedProducts.length) {
                              return _buildProductCard(
                                  _displayedProducts[index]);
                            } else {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                      color: _categoryColor),
                                ),
                              );
                            }
                          },
                          childCount: _displayedProducts.length +
                              (_isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
