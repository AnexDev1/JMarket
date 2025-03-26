// File: lib/features/product/product_details_screen.dart
// Language: dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../data/datasources/remote/supabase_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<Map<String, dynamic>> _futureProduct;
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;
  String _selectedSize = 'M';

  @override
  void initState() {
    super.initState();
    _futureProduct = SupabaseService().fetchProductById(widget.productId);
  }

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return Future.value(false);
    } else {
      context.go('/');
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _futureProduct,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child:
                      Text('Error: ${snapshot.error}', style: TextStyles.body1),
                );
              } else if (snapshot.hasData) {
                final product = snapshot.data!;
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 0,
                      floating: true,
                      pinned: true,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _onWillPop();
                        },
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Share functionality')),
                            );
                          },
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageCarousel(product),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product['name'] ?? 'No Name',
                                        style: TextStyles.heading3,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_outline,
                                        color: _isFavorite
                                            ? AppColors.error
                                            : AppColors.gray600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isFavorite = !_isFavorite;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(_isFavorite
                                                ? 'Added to favorites'
                                                : 'Removed from favorites'),
                                            duration:
                                                const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text('\$${product['price']}',
                                    style: TextStyles.heading4),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${product['rating']}',
                                      style: TextStyles.body1.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${product['reviews']} reviews)',
                                      style: TextStyles.body2
                                          .copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Text(
                                  'Size',
                                  style: TextStyles.body1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildSizeSelector(product),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    _buildQuantitySelector(),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${product['name']} added to cart'),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                        ),
                                        child: Text(
                                          'Add to Cart | \$${(product['price'] * _quantity).toStringAsFixed(2)}',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),
                                Text(
                                  'Description',
                                  style: TextStyles.body1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product['description'] ?? '',
                                  style: TextStyles.body2,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Key Features',
                                  style: TextStyles.body1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildFeaturesList(product),
                                const Divider(height: 32),
                                Text(
                                  'You May Also Like',
                                  style: TextStyles.body1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                _buildRelatedProducts(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Map<String, dynamic> product) {
    final List images = product['image_urls'] ?? [];
    return SizedBox(
      height: 300,
      child: images.isNotEmpty
          ? PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.gray200,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: AppColors.gray500,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Container(
              height: 300,
              color: AppColors.gray200,
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: AppColors.gray500,
                ),
              ),
            ),
    );
  }

  Widget _buildSizeSelector(Map<String, dynamic> product) {
    final List sizes = product['sizes'] ?? ['M'];
    return Row(
      children: sizes.map<Widget>((size) {
        final bool isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSize = size;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlack : AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlack : AppColors.gray300,
              ),
            ),
            child: Center(
              child: Text(
                size,
                style: TextStyles.body1.copyWith(
                  color: isSelected
                      ? AppColors.primaryWhite
                      : AppColors.primaryBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
          ),
          SizedBox(
            width: 40,
            child: Center(
              child: Text('$_quantity', style: TextStyles.body1),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                _quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed == null ? AppColors.gray400 : AppColors.primaryBlack,
      ),
    );
  }

  Widget _buildFeaturesList(Map<String, dynamic> product) {
    final List features = product['features'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map<Widget>((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 18, color: AppColors.gray700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(feature, style: TextStyles.body2),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRelatedProducts() {
    final List<Map<String, dynamic>> relatedProducts = [
      {
        'id': '2',
        'name': 'Bluetooth Speaker',
        'price': 59.99,
        'rating': 4.3,
        'image': 'https://example.com/speaker.jpg',
      },
      {
        'id': '3',
        'name': 'Wireless Earbuds',
        'price': 79.99,
        'rating': 4.7,
        'image': 'https://example.com/earbuds.jpg',
      },
      {
        'id': '4',
        'name': 'Audio Cable',
        'price': 19.99,
        'rating': 4.1,
        'image': 'https://example.com/cable.jpg',
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatedProducts.length,
        itemBuilder: (context, index) {
          final product = relatedProducts[index];
          return GestureDetector(
            onTap: () {
              context.go('/product-details/${product['id']}');
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Image.network(
                        product['image'],
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image,
                              size: 30, color: AppColors.gray500);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: TextStyles.caption
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('\$${product['price']}',
                            style: TextStyles.caption),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text('${product['rating']}',
                                style: TextStyles.caption),
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
    );
  }
}
