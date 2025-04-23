// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';

import '../data/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  // Maximum allowed quantity per item
  static const int maxQuantity = 10;

  // Get items in cart
  List<CartItem> get items => [..._items];

  // Get total number of items
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Get total price
  double get totalPrice => _items.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

  // Check if cart contains item
  bool containsItem(String productId, String? size) {
    return _items
        .any((item) => item.productId == productId && item.size == size);
  }

  // Get specific item
  CartItem? getItem(String productId, String? size) {
    try {
      return _items.firstWhere(
        (item) => item.productId == productId && item.size == size,
      );
    } catch (e) {
      return null;
    }
  }

  void addProduct(Map<String, dynamic> product) {
    final String productId = product['id'].toString();
    final String productName = product['name'] ?? 'Unknown';
    final double price = (product['price'] as num).toDouble();
    final int quantity = 1; // Default quantity
    final String imageUrl = (product['image_urls'] != null &&
            (product['image_urls'] as List).isNotEmpty)
        ? product['image_urls'][0]
        : '';
    final String? size = product['size'];
    final String? color = product['color'];

    addItem(productId, productName, price, quantity, imageUrl, size,
        color: color);
  }

  // Add item to cart - supports both positional and named parameters
  void addItem(
    String productId,
    String productName,
    double price,
    int quantity,
    String imageUrl,
    String? size, {
    String? color,
  }) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final existingItem = _items[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;

      // Enforce maximum quantity using copyWith
      if (newQuantity <= maxQuantity) {
        _items[existingItemIndex] =
            existingItem.copyWith(quantity: newQuantity);
      } else {
        _items[existingItemIndex] =
            existingItem.copyWith(quantity: maxQuantity);
      }
    } else {
      // Add new item
      _items.add(
        CartItem(
          productId: productId,
          productName: productName,
          price: price,
          quantity: quantity.clamp(1, maxQuantity),
          imageUrl: imageUrl,
          size: size,
          color: color,
        ),
      );
    }
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String productId, String? size) {
    _items.removeWhere(
      (item) => item.productId == productId && item.size == size,
    );
    notifyListeners();
  }

  // Increase item quantity
  void increaseQuantity(String productId, String? size) {
    final index = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (index >= 0 && _items[index].quantity < maxQuantity) {
      // Use copyWith to create a new instance with increased quantity
      _items[index] =
          _items[index].copyWith(quantity: _items[index].quantity + 1);
      notifyListeners();
    }
  }

  // Decrease item quantity
  void decreaseQuantity(String productId, String? size) {
    final index = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        // Use copyWith to create a new instance with decreased quantity
        _items[index] =
            _items[index].copyWith(quantity: _items[index].quantity - 1);
      } else {
        // Remove item if quantity becomes zero
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Add this method to your CartProvider class
  void updateItemQuantity(String productId, String? size, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, size);
      return;
    }

    final index = _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );

    if (index >= 0) {
      // Use copyWith to update quantity
      _items[index] =
          _items[index].copyWith(quantity: quantity.clamp(1, maxQuantity));
      notifyListeners();
    }
  }

  // Clear cart
  void clear() {
    _items = [];
    notifyListeners();
  }

  // Save cart for later
  void saveForLater(String productId, String? size) {
    // Implementation for saving items for later
    // This could store items in a separate list or database
    notifyListeners();
  }

  // Check if eligible for free shipping
  bool get isEligibleForFreeShipping => totalPrice >= 100;

  // Get shipping cost
  double get shippingCost => isEligibleForFreeShipping ? 0.0 : 10.0;

  // Get tax amount (assuming 8% tax rate)
  double get taxAmount => totalPrice * 0.08;

  // Get final total including tax and shipping
  double get finalTotal => totalPrice + taxAmount + shippingCost;
}
