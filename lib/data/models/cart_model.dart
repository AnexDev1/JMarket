class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String? size;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.size,
    this.imageUrl,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    String? size,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.productId == productId &&
        other.size == size;
  }

  @override
  int get hashCode => productId.hashCode ^ (size?.hashCode ?? 0);
}

class Cart {
  final List<CartItem> _items = [];

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => _items.isEmpty;

  // Find an item in cart
  int _findItemIndex(String productId, String? size) {
    return _items.indexWhere(
      (item) => item.productId == productId && item.size == size,
    );
  }

  // Add item to cart
  void addItem(CartItem item) {
    final existingIndex = _findItemIndex(item.productId, item.size);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      _items[existingIndex].quantity += item.quantity;
    } else {
      // Add new item
      _items.add(item);
    }
  }

  // Remove item from cart
  void removeItem(String productId, String? size) {
    final existingIndex = _findItemIndex(productId, size);
    if (existingIndex >= 0) {
      _items.removeAt(existingIndex);
    }
  }

  // Update quantity
  void updateQuantity(String productId, String? size, int quantity) {
    final existingIndex = _findItemIndex(productId, size);
    if (existingIndex >= 0) {
      if (quantity <= 0) {
        removeItem(productId, size);
      } else {
        _items[existingIndex].quantity = quantity;
      }
    }
  }

  // Increment quantity
  void incrementQuantity(String productId, String? size) {
    final existingIndex = _findItemIndex(productId, size);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    }
  }

  // Decrement quantity
  void decrementQuantity(String productId, String? size) {
    final existingIndex = _findItemIndex(productId, size);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        removeItem(productId, size);
      }
    }
  }

  // Clear cart
  void clear() {
    _items.clear();
  }

  // Check if item exists in cart
  bool containsItem(String productId, String? size) {
    return _findItemIndex(productId, size) >= 0;
  }
}
