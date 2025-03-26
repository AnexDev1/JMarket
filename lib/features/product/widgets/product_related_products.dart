import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductRelatedProducts extends StatefulWidget {
  const ProductRelatedProducts({super.key});

  @override
  State<ProductRelatedProducts> createState() => _ProductRelatedProductsState();
}

class _ProductRelatedProductsState extends State<ProductRelatedProducts> {
  late Future<List<Map<String, dynamic>>> _futureRelatedProducts;
  final primaryColor = Colors.indigo.shade700;

  @override
  void initState() {
    super.initState();
    // Simulate fetching related products
    _futureRelatedProducts = Future.delayed(
      const Duration(seconds: 1),
      () => _getMockRelatedProducts(),
    );
  }

  List<Map<String, dynamic>> _getMockRelatedProducts() {
    return [
      {
        'id': '101',
        'name': 'Canvas Sneakers',
        'price': 59.99,
        'image_url': 'https://picsum.photos/id/24/200/200',
        'rating': 4.5,
      },
      {
        'id': '102',
        'name': 'Running Shoes',
        'price': 89.99,
        'image_url': 'https://picsum.photos/id/21/200/200',
        'rating': 4.7,
      },
      {
        'id': '103',
        'name': 'Leather Boots',
        'price': 129.99,
        'image_url': 'https://picsum.photos/id/15/200/200',
        'rating': 4.8,
      },
      {
        'id': '104',
        'name': 'Hiking Shoes',
        'price': 99.99,
        'image_url': 'https://picsum.photos/id/36/200/200',
        'rating': 4.6,
      },
    ];
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
        // Navigate to the product detail page
        GoRouter.of(context).push('/product/${product['id']}');
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
            // Product Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  product['image_url'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']}',
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
                        '${product['rating']}',
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
