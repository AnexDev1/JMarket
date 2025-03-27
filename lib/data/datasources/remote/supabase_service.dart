// lib/data/datasources/remote/supabase_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Auth methods
  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  bool get isAuthenticated => currentUser != null;

// dart
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    // Sign up the user with Supabase Auth.
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': userData['full_name'],
      },
    );

    // If the user is successfully created in auth.
    if (response.user != null) {
      final upsertResponse = await client.from('users').upsert({
        'id': response.user!.id, // primary key.
        'email': email,
        'full_name': userData['full_name'],
        'phone': userData['phone'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.yourappname://reset-callback',
    );
  }

  Future<bool> signInWithGoogle() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.yourappname://login-callback',
    );
  }

  Future<bool> signInWithFacebook() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: kIsWeb ? null : 'io.supabase.yourappname://login-callback',
    );
  }

  // Existing product methods
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
