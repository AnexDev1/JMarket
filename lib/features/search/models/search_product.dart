// dart
import 'dart:ui';

class SearchProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final String imageUrl;
  final Color color;
  final List<String> keyFeatures;

  const SearchProduct(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.rating,
      required this.reviews,
      required this.imageUrl,
      required this.color,
      required this.keyFeatures});

  factory SearchProduct.fromMap(Map<String, dynamic> map) {
    // Retrieve the first image URL from the list
    String imageUrl = '';
    if (map['imageUrls'] is List && (map['imageUrls'] as List).isNotEmpty) {
      imageUrl = (map['imageUrls'] as List).first.toString();
    }
    // Use a placeholder URL if no valid image URL is found.
    if (imageUrl.isEmpty) {
      imageUrl = 'https://via.placeholder.com/150';
    }

    return SearchProduct(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: map['price'] is num ? (map['price'] as num).toDouble() : 0.0,
      rating: map['rating'] is num ? (map['rating'] as num).toDouble() : 0.0,
      reviews: map['reviews'] is num ? (map['reviews'] as num).toInt() : 0,
      imageUrl: imageUrl,
      color: map['color'] != null
          ? Color(map['color'] as int)
          : const Color(0x00000000),
      keyFeatures: map['key_features'] != null
          ? List<String>.from((map['key_features'] as List)
              .map((e) => e.toString().replaceAll('\"', '')))
          : [],
    );
  }

  factory SearchProduct.fromJson(Map<String, dynamic> json) {
    return SearchProduct.fromMap(json);
  }
}
