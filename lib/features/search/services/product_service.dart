// lib/features/search/services/product_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/search_product.dart';

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SearchProduct>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .limit(20)
          .order('created_at', ascending: false);

      print('Search response: $response');

      return response.map<SearchProduct>((product) {
        // Fix the field mapping - use image_urls[0] if it exists
        String imageUrl = '';
        if (product['image_urls'] != null &&
            product['image_urls'] is List &&
            product['image_urls'].isNotEmpty) {
          imageUrl = product['image_urls'][0];
        }

        return SearchProduct(
          id: product['id'].toString(),
          name: product['name'] ?? '',
          description: product['description'] ?? '',
          price: (product['price'] is int)
              ? (product['price'] as int).toDouble()
              : (product['price'] ?? 0).toDouble(),
          rating: (product['rating'] is int)
              ? (product['rating'] as int).toDouble()
              : (product['rating'] ?? 0).toDouble(),
          reviews: product['reviews'] ?? 0,
          imageUrl: imageUrl, // This must match the constructor parameter name
          color: _getColorFromHex(product['color_hex'] ?? '#6200EA'),
        );
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Helper method to convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
