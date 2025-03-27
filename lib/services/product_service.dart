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
}
