import 'package:flutter/foundation.dart';

import '../data/models/cart_model.dart';

// Import model from previous implementation
// Assuming the Cart and CartItem models are in 'models/cart.dart'

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  // Getters to access cart properties
  List<CartItem> get items => _cart.items;
  int get itemCount => _cart.itemCount;
  double get totalPrice => _cart.totalPrice;
  bool get isEmpty => _cart.isEmpty;

  // Add a product to cart
  void addItem({
    required String productId,
    required String productName,
    required double price,
    String? size,
    String? imageUrl,
    int quantity = 1,
  }) {
    _cart.addItem(
      CartItem(
        productId: productId,
        productName: productName,
        price: price,
        size: size,
        imageUrl: imageUrl,
        quantity: quantity,
      ),
    );
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String productId, String? size) {
    _cart.removeItem(productId, size);
    notifyListeners();
  }

  // Increment item quantity
  void incrementQuantity(String productId, String? size) {
    _cart.incrementQuantity(productId, size);
    notifyListeners();
  }

  // Decrement item quantity
  void decrementQuantity(String productId, String? size) {
    _cart.decrementQuantity(productId, size);
    notifyListeners();
  }

  // Update quantity directly
  void updateQuantity(String productId, String? size, int quantity) {
    _cart.updateQuantity(productId, size, quantity);
    notifyListeners();
  }

  // Check if product exists in cart
  bool containsItem(String productId, String? size) {
    return _cart.containsItem(productId, size);
  }

  // Clear the entire cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
