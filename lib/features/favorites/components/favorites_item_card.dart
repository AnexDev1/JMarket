// dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../../providers/favorites_provider.dart';

class FavoriteItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const FavoriteItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.go('/product-details/${item['id']}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(),
              _buildProductDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Builder(builder: (context) {
      final localizations = AppLocalizations.of(context)!;
      return Stack(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: _getProductImage(),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _buildFavoriteButton(),
          ),
          if (item['discount'] != null && item['discount'] > 0)
            Positioned(
              top: 8,
              left: 8,
              child: _buildDiscountBadge(localizations),
            ),
        ],
      );
    });
  }

  Widget _getProductImage() {
    final hasImages =
        item['image_urls'] != null && (item['image_urls'] as List).isNotEmpty;
    if (hasImages) {
      return Image.network(
        item['image_urls'][0],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Builder(builder: (context) {
      final localizations = AppLocalizations.of(context)!;
      return Material(
        elevation: 2,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            final favoritesProvider =
                Provider.of<FavoritesProvider>(context, listen: false);
            favoritesProvider.removeFavorite(item['id'].toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${item['name']} ${localizations.removedFromFavorites}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.favorite,
              size: 20,
              color: Colors.red.shade400,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDiscountBadge(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade500,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${item['discount']}% ${localizations.off}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'] ?? localizations.unknownProduct,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _buildPriceRow(),
            const SizedBox(height: 4),
            _buildRating(),
            const Spacer(),
            _buildAddToCartText(context, localizations),
          ],
        ),
      ),
    );
  }

// dart
  Widget _buildAddToCartText(
      BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Colors.indigo, // Use the same primary color as details page
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final price = item['price'] is int
            ? (item['price'] as int).toDouble()
            : item['price'] is double
                ? item['price']
                : double.parse(item['price'].toString());
        cartProvider.addItem(
          item['id'].toString(),
          item['name'] ?? 'No name',
          price,
          item['quantity'] ?? 1,
          item['image_urls'] != null && (item['image_urls'] as List).isNotEmpty
              ? item['image_urls'][0]
              : '',
          '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} added to cart'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Text(
        localizations.addToCart,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    final hasDiscount = item['discount'] != null && item['discount'] > 0;
    final price = double.parse(item['price'].toString());
    if (hasDiscount) {
      final discount = double.parse(item['discount'].toString()) / 100;
      final originalPrice = price / (1 - discount);
      return Row(
        children: [
          Text(
            '${price.toStringAsFixed(2)} ETB',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.indigo.shade700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${originalPrice.toStringAsFixed(2)} ETB',
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      );
    }
    return Text(
      '${price.toStringAsFixed(2)} ETB',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.indigo.shade700,
      ),
    );
  }

  Widget _buildRating() {
    final hasRating = item['rating'] != null;
    if (!hasRating) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          item['rating'].toString(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
