// File: lib/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Product> getProductById(String productId) async {
    final response = await _supabase
        .from('products')
        .select('*')
        .eq('id', productId)
        .single();
    return Product.fromJson(response);
  }

  // Add this method to ProductService class
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category, {
    String? excludeProductId,
    int limit = 10,
  }) async {
    try {
      var query =
          _supabase.from('products').select('*').eq('category', category);

      // Add exclusion filter if an ID is provided
      if (excludeProductId != null) {
        query = query.not('id', 'eq', excludeProductId);
      }

      final response = await query;

      // Convert response to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch related products: $e');
    }
  }
}
