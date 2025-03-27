import 'cart_model.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final List<String> imageUrls;
  final List<String>? availableSizes;
  final bool inStock;
  final double? discountPercentage;
  final double? rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrls,
    this.availableSizes,
    this.inStock = true,
    this.discountPercentage,
    this.rating,
  });

  // Calculate discounted price if discount is available
  double get discountedPrice {
    if (discountPercentage == null || discountPercentage! <= 0) {
      return price;
    }
    return price * (1 - discountPercentage! / 100);
  }

  // Check if product has different size options
  bool get hasSizeOptions =>
      availableSizes != null && availableSizes!.isNotEmpty;

// Create CartItem from this product
  CartItem toCartItem({String? size, int quantity = 1}) {
    return CartItem(
      productId: id,
      productName: name,
      price: discountedPrice,
      size: size,
      // Fix the null error by providing a fallback empty string
      imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '',
      quantity: quantity,
    );
  }

// Dart
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrls:
          json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : [],
      availableSizes: json['availableSizes'] != null
          ? List<String>.from(json['availableSizes'])
          : null,
      inStock: json['inStock'] ?? true,
      discountPercentage: json['discountPercentage'] != null
          ? (json['discountPercentage'] as num).toDouble()
          : null,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }
  // Copy with method for immutability
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    List<String>? imageUrls,
    List<String>? availableSizes,
    bool? inStock,
    double? discountPercentage,
    double? rating,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      availableSizes: availableSizes ?? this.availableSizes,
      inStock: inStock ?? this.inStock,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
