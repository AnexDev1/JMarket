import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/product_service.dart';

class ProductRelatedProducts extends StatefulWidget {
  final String category;
  final String currentProductId;

  const ProductRelatedProducts({
    super.key,
    required this.category,
    required this.currentProductId,
  });

  @override
  State<ProductRelatedProducts> createState() => _ProductRelatedProductsState();
}

class _ProductRelatedProductsState extends State<ProductRelatedProducts> {
  late Future<List<Map<String, dynamic>>> _futureRelatedProducts;
  final primaryColor = Colors.indigo.shade700;

  @override
  void initState() {
    super.initState();
    _fetchRelatedProducts();
  }

  void _fetchRelatedProducts() {
    _futureRelatedProducts = ProductService().getProductsByCategory(
      widget.category,
      excludeProductId: widget.currentProductId,
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureRelatedProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load related products',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No related products available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          final products = snapshot.data!;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildRelatedProductCard(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildRelatedProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/product-details/${product['id']}');
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
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
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  product['image_url'] ?? product['image_urls']?[0] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['price'] ?? 0} ETB',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${product['rating'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
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
  }
}
