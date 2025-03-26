// File: lib/data/datasources/remote/supabase_service.dart
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;
// Add to SupabaseService class
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

  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> imageUrls = [];
    for (var imageFile in imageFiles) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final bytes = await imageFile.readAsBytes();
      final uploadResponse =
          await client.storage.from('jmarket').uploadBinary(fileName, bytes);

      // Get the public url
      final publicUrlResponse =
          client.storage.from('jmarket').getPublicUrl(fileName);
      final publicUrl = publicUrlResponse;
      if (publicUrl.isNotEmpty) {
        imageUrls.add(publicUrl);
      } else {
        throw Exception('Failed to get public URL for $fileName');
      }
    }
    return imageUrls;
  }

  Future<List<Map<String, dynamic>>> fetchProducts({String? category}) async {
    var query = client.from('products').select();
    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }
    final response = await query;

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> fetchProductById(String productId) async {
    final response =
        await client.from('products').select().eq('id', productId).single();

    return response;
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    final response = await client.from('products').insert(productData);
    return response;
  }
}
