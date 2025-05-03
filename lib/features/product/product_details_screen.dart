import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:jmarket/data/models/product_model.dart';
import 'package:jmarket/services/product_service.dart';
import 'package:jmarket/services/user_service.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/custom_snackbar.dart';
import 'widgets/product_features_list.dart';
import 'widgets/product_image_carousel.dart';
import 'widgets/product_quantity_selector.dart';
import 'widgets/product_related_products.dart';
import 'widgets/product_size_selector.dart';

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
  late var _futureProduct;
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool isFavorite = false;
  String _selectedSize = 'M';
  // ignore: unused_field
  bool _isAuthenticated = false;
  final Color primaryColor = Colors.indigo.shade700;

  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _futureProduct = ProductService().getProductById(widget.productId);
    _checkAuthentication();
    // Listen to scroll to show/hide title in app bar
    _scrollController.addListener(() {
      setState(() {
        _showTitle = _scrollController.offset > 180;
      });
    });
  }

  Future<void> _checkAuthentication() async {
    final currentUser = await UserService().getCurrentUser();
    setState(() {
      _isAuthenticated = currentUser != null;
    });
  }

  // Future<void> _submitRating(double rating) async {
  //   try {
  //     await ProductService().submitProductRating(widget.productId, rating);
  //     setState(() {
  //       _futureProduct = ProductService().getProductById(widget.productId);
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AppLocalizations.of(context)!.ratingSubmitted),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AppLocalizations.of(context)!.errorSubmittingRating),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return Future.value(false);
    } else {
      context.push('/');
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: SafeArea(
              child: FutureBuilder<Product>(
            future: _futureProduct,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.loadingProductDetails,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        localizations.errorLoadingProduct,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _futureProduct = ProductService()
                                .getProductById(widget.productId);
                          });
                        },
                        child: Text(localizations.tryAgain),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                final product = snapshot.data!;
                final favoritesProvider =
                    Provider.of<FavoritesProvider>(context);
                isFavorite =
                    favoritesProvider.isFavorite(product.id.toString());

                return CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 0,
                      floating: true,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      foregroundColor: Colors.black87,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                        onPressed: () => _onWillPop(),
                      ),
                      title: _showTitle
                          ? Text(
                              product.name.isNotEmpty
                                  ? product.name
                                  : localizations.productDetails,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      actions: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.share_outlined, size: 20),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text(localizations.shareFunctionality)),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Image Carousel
                          Hero(
                            tag: 'product-${product.id}',
                            child: Container(
                              height: 300,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Main Image Carousel
                                  ProductImageCarousel(
                                    images: product.imageUrls,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    },
                                  ),

                                  // Favorite Button
                                  // dart
                                  Positioned(
                                    right: 16,
                                    top: 16,
                                    child: GestureDetector(
                                      onTap: () {
                                        final favoritesProvider =
                                            Provider.of<FavoritesProvider>(
                                                context,
                                                listen: false);
                                        favoritesProvider
                                            .toggleFavorite(product);
                                        // Call setState to update the UI after toggling
                                        setState(() {});
                                        final updatedIsFavorite =
                                            favoritesProvider.isFavorite(
                                                product.id.toString());

                                        CustomSnackbar.showSuccessSnackBar(
                                          context,
                                          updatedIsFavorite
                                              ? localizations.addedToFavorites
                                              : localizations
                                                  .removedFromFavorites,
                                          '',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: .1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Discount Tag
                                  if (product.discountPercentage != null &&
                                      product.discountPercentage! > 0)
                                    Positioned(
                                      left: 16,
                                      top: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          localizations.discountPercent(
                                              product.discountPercentage!),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Image Indicators
                                  if (product.imageUrls.length > 1)
                                    Positioned(
                                      bottom: 16,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          product.imageUrls.length,
                                          (index) => Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: index == _currentImageIndex
                                                  ? primaryColor
                                                  : Colors.grey
                                                      .withValues(alpha: .5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Product Info Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if (product.brand != null)
                                //   Text(
                                //     product.brand!,
                                //     style: const TextStyle(
                                //       fontSize: 14,
                                //       color: Colors.grey,
                                //       fontWeight: FontWeight.w500,
                                //     ),
                                //   ),
                                Text(
                                  product.name.isNotEmpty
                                      ? product.name
                                      : localizations.noName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < (product.rating ?? 0)
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${product.rating}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.reviewsCount(4),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${product.price} ETB',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    if (product.discountPercentage != null &&
                                        product.discountPercentage! > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '\$${(product.price * (1 + product.discountPercentage! / 100)).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (product.category.toLowerCase() ==
                                        'clothing' ||
                                    product.category.toLowerCase() ==
                                        'sports') ...[
                                  Text(
                                    localizations.selectSize,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ProductSizeSelector(
                                    sizes: const ['S', 'M', 'L', 'XL', 'XXL'],
                                    selectedSize: _selectedSize,
                                    onSizeSelected: (size) {
                                      setState(() {
                                        _selectedSize = size;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Description
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(24),
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product.description.isNotEmpty
                                      ? product.description
                                      : localizations.noDescriptionAvailable,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Key Features
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(24),
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.keyFeatures,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ProductFeaturesList(
                                    features: product.keyFeatures ?? []),
                              ],
                            ),
                          ),

                          // Related Products
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(24),
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.youMayAlsoLike,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ProductRelatedProducts(
                                  category: product.category,
                                  currentProductId: product.id.toString(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          )),
        ),
        // Floating Add to Cart Panel
        // dart
        bottomNavigationBar: FutureBuilder<Product>(
          future: _futureProduct,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final product = snapshot.data!;
            final bool inStock = product.inStock;

            // Hide the add to cart panel if not in stock.
            if (!inStock) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ProductQuantitySelector(
                    quantity: _quantity,
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        _quantity = newQuantity;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final cartProvider = context.read<CartProvider>();
                        cartProvider.addItem(
                          product.id.toString(),
                          product.name,
                          double.parse(product.price.toString()),
                          _quantity,
                          (product.imageUrls as List).isNotEmpty
                              ? product.imageUrls[0]
                              : '',
                          _selectedSize,
                        );
                        CustomSnackbar.showSuccessSnackBar(
                          context,
                          'Added to Cart',
                          localizations.addedToCart(product.name),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        localizations.addToCartWithPrice(
                            "${(product.price * _quantity).toStringAsFixed(2)} ETB"),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProductRatingWidget extends StatefulWidget {
  final String productId;
  final bool isAuthenticated;
  final Function(double) onRatingSubmitted;

  const ProductRatingWidget({
    Key? key,
    required this.productId,
    required this.isAuthenticated,
    required this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<ProductRatingWidget> createState() => _ProductRatingWidgetState();
}

class _ProductRatingWidgetState extends State<ProductRatingWidget> {
  double _selectedRating = 0;
  bool _hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (!widget.isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            const Icon(Icons.star_border, color: Colors.grey),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.push('/login'),
              child: Text(localizations.loginToRate),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          localizations.rateThisProduct,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            5,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = index + 1;
                  _hasSubmitted = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
        if (_selectedRating > 0 && !_hasSubmitted) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onRatingSubmitted(_selectedRating);
              setState(() {
                _hasSubmitted = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.submitRating),
          ),
        ],
        if (_hasSubmitted) ...[
          const SizedBox(height: 12),
          Text(
            localizations.thankYouForRating,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
