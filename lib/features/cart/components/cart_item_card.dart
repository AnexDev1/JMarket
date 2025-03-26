// lib/features/cart/components/cart_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/cart_model.dart';
import '../../../providers/cart_provider.dart';
import 'quantity_button.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartProvider cartProvider;

  const CartItemCard({
    super.key,
    required this.item,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.productId.toString() + (item.size ?? '')),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        cartProvider.removeItem(item.productId, item.size);
        ScaffoldMessenger.of(context)
            .showSnackBar(_buildRemovedSnackBar(context));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(),
                    const SizedBox(height: 12),
                    _buildQuantityControls(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: item.imageUrl.isNotEmpty
            ? Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey.shade400,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey.shade400,
                ),
              ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        if (item.size != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Size: ${item.size}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.indigo.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Row(
      children: [
        QuantityButton(
          icon: Icons.remove,
          onPressed: item.quantity > 1
              ? () {
                  HapticFeedback.lightImpact();
                  cartProvider.updateItemQuantity(
                    item.productId,
                    item.size,
                    item.quantity - 1,
                  );
                }
              : null,
        ),
        Container(
          width: 40,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        QuantityButton(
          icon: Icons.add,
          onPressed: item.quantity < 10
              ? () {
                  HapticFeedback.lightImpact();
                  cartProvider.updateItemQuantity(
                    item.productId,
                    item.size,
                    item.quantity + 1,
                  );
                }
              : null,
        ),
        const Spacer(),
        Text(
          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  SnackBar _buildRemovedSnackBar(BuildContext context) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.remove_shopping_cart, color: Colors.white, size: 16),
          const SizedBox(width: 12),
          Text('${item.productName} removed from cart'),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.grey.shade800,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.indigo.shade200,
        onPressed: () {
          cartProvider.addItem(
            item.productId,
            item.productName,
            item.price,
            item.quantity,
            item.imageUrl,
            item.size,
          );
        },
      ),
    );
  }
}
