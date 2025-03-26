import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy cart items - would come from a provider in a real app
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Wireless Headphones',
      'price': 89.99,
      'quantity': 1,
      'image': 'headphones.jpg'
    },
    {
      'id': '2',
      'name': 'Smart Watch',
      'price': 199.99,
      'quantity': 1,
      'image': 'watch.jpg'
    },
    {
      'id': '3',
      'name': 'Portable Charger',
      'price': 49.99,
      'quantity': 2,
      'image': 'charger.jpg'
    },
  ];

  double get _subtotal => _cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get _tax => _subtotal * 0.08; // 8% tax
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItem(item, index);
                    },
                  ),
                ),
                _buildCartSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyles.heading4,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyles.body1.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.primaryWhite,
        ),
      ),
      onDismissed: (_) {
        setState(() {
          _cartItems.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['name']} removed from cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.image,
                size: 40,
                color: AppColors.gray500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item['price']}',
                  style: TextStyles.body2,
                ),
                const SizedBox(height: 12),
                // Quantity selector
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: item['quantity'] > 1
                          ? () => _updateQuantity(index, item['quantity'] - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '${item['quantity']}',
                          style: TextStyles.body1,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () =>
                          _updateQuantity(index, item['quantity'] + 1),
                    ),
                    const Spacer(),
                    Text(
                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: TextStyles.body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed == null ? AppColors.gray200 : AppColors.gray100,
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: onPressed == null ? AppColors.gray400 : AppColors.primaryBlack,
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', _subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow('Tax (8%)', _tax),
          const Divider(height: 24),
          _buildSummaryRow('Total', _total, isTotal: true),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to checkout
              context.go('/checkout');
            },
            child: Text('Proceed to Checkout (\$${_total.toStringAsFixed(2)})'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? TextStyles.body1.copyWith(fontWeight: FontWeight.bold)
              : TextStyles.body1,
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: isTotal
              ? TextStyles.body1.copyWith(fontWeight: FontWeight.bold)
              : TextStyles.body1,
        ),
      ],
    );
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      _cartItems[index]['quantity'] = quantity;
    });
  }
}
