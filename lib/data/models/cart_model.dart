// lib/data/models/cart_model.dart

class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;
  final String imageUrl;
  final String? size;
  final String? color;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.size,
    this.color,
  });

  double get totalPrice => price * quantity;
  String get name => productName;
  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageUrl,
    String? size,
    String? color,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}
