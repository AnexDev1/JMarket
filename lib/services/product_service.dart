// File: lib/services/search_product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/product_model.dart';

class ProductService {
  final SupabaseClient client = Supabase.instance.client;

  Future<Product> getProductById(String productId) async {
    final response =
        await client.from('products').select('*').eq('id', productId).single();
    return Product.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> fetchProducts({String? category}) async {
    var query = client.from('products').select();
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    final response = await query;

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await client
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .order('rating', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Add this method to ProductService class
  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String category, {
    String? excludeProductId,
    int limit = 10,
  }) async {
    try {
      var query = client.from('products').select('*').eq('category', category);

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

  Future<void> submitProductRating(String productId, double rating) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get the current product data
    final product = await client
        .from('products')
        .select('rating, reviews')
        .eq('id', productId)
        .single();

    // Calculate new rating
    final currentRating = double.tryParse(product['rating'] ?? '0') ?? 0;
    final reviewCount = product['reviews'] ?? 0;

    // Simple average calculation (this is simplified; in a real app you'd store individual ratings)
    double newRating;
    if (reviewCount == 0) {
      newRating = rating;
    } else {
      // Weight the new rating appropriately
      newRating = ((currentRating * reviewCount) + rating) / (reviewCount + 1);
    }

    // Update product with new rating
    await client.from('products').update({
      'rating': newRating.toStringAsFixed(1),
      'reviews': reviewCount + 1
    }).eq('id', productId);
  }
}
