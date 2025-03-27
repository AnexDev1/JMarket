// lib/features/search/models/search_product.dart
import 'package:flutter/material.dart';

class SearchProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final String imageUrl;
  final Color color;

  const SearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.color,
  });

  factory SearchProduct.fromMap(Map<String, dynamic> map) {
    return SearchProduct(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      reviews: map['reviews'] as int,
      imageUrl: map['imageUrls'][0] ?? '',
      color: map['color'] as Color,
    );
  }
}
