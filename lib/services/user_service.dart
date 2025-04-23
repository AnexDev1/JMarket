// lib/services/user_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_model.dart';

class UserService {
  final SupabaseClient client = Supabase.instance.client;
  // Auth methods
  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  bool get isAuthenticated => currentUser != null;
  // Get all users.
  Future<List<UserModel>> getAllUsers() async {
    final response = await client.from('users').select('*');
    return (response as List).map((user) => UserModel.fromJson(user)).toList();
  }

  Future<void> deleteUser(String userId) async {
    try {
      await client.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user data: ${e.toString()}');
    }
  }

  Future<UserModel> getUserById(String userId) async {
    final response = await client
        .from('users')
        .select('full_name, email, phone')
        .eq('id', userId)
        .single();
    return UserModel.fromJson(response);
  }

  // Create a new user.
  Future<UserModel> createUser(UserModel user) async {
    final response =
        await client.from('users').insert(user.toJson()).select().single();
    print(response);
    return UserModel.fromJson(response);
  }

  Future<List<UserModel>> fetchAdminUsers() async {
    final response = await client.from('users').select('*').eq('role', 'admin');
    return (response as List).map((user) => UserModel.fromJson(user)).toList();
  }



  Future<User?> getCurrentUser() async {
    return client.auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final response =
          await client.from('users').select().eq('id', userId).single();
      return response;
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      return null;
    }
  }

  Future<void> deleteUserData(String userId) async {
    try {
      // Delete user profile data first
      await client.from('users').delete().eq('id', userId);

      // Delete related data (adapt these to your actual database tables)
      await client.from('orders').delete().eq('user_id', userId);
      await client.from('cart_items').delete().eq('user_id', userId);
      // Add other tables as needed
    } catch (e) {
      throw Exception('Failed to delete user data: ${e.toString()}');
    }
  }

  Future<void> updateUserDetails(String userId, Map<String, dynamic> data) async {
    try {
      await client.from('users').update(data).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user details: ${e.toString()}');
    }
  }

}