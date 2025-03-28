import 'package:flutter/material.dart';

import '../../services/product_service.dart';

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
  List<Map<String, dynamic>> _products = [];
  final _scrollController = ScrollController();
  String _sortBy = 'popular';

  // Store category properties with defaults
  late String _categoryName;
  late Color _categoryColor;
  late IconData _categoryIcon;

  @override
  void initState() {
    super.initState();
    _initializeCategoryData();
    _loadProducts();
  }

  void _initializeCategoryData() {
    // Set defaults first
    _categoryName = 'Category';
    _categoryColor = Colors.blue;
    _categoryIcon = Icons.category;

    // Try to get from widget.category if available
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

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _products = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          _isLoading ? SliverToBoxAdapter() : _buildFilterBar(),
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _categoryColor,
                    ),
                  ),
                )
              : _products.isEmpty
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
                          (context, index) =>
                              _buildProductCard(_products[index]),
                          childCount: _products.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      pinned: true,
      title: Text(_categoryName), // Add direct title as fallback
      flexibleSpace: FlexibleSpaceBar(
        // Remove title from FlexibleSpaceBar
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
        // Remove collapseMode to use default
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Show search
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Show filters
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
          // Option 1: Change background color
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${_products.length} products',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Make this text darker too
              Text('Sort by:', style: TextStyle(color: Colors.grey[800])),
              const SizedBox(width: 8),
              // Option 2: Theme to control dropdown appearance
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor:
                      Colors.white, // Background of dropdown menu items
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  isDense: true,
                  underline: const SizedBox(),
                  // Option 3: Explicit text styling
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
                      setState(() => _sortBy = value);
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Safe access for product data
    final id = product['id'] ?? '';
    final name = product['name'] ?? 'Unknown Product';
    final price = product['price'] ?? 0;
    final rating = product['rating'] ?? 0;

    // Safe handling of image urls
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
            // Navigate to product details
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
