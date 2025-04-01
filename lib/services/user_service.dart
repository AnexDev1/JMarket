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

  // Get a single user by its ID.
  // File: lib/services/user_service.dart
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

  Future<void> deleteUser(String userId) async {
    await client.from('users').delete().eq('id', userId);
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
  // // Update an existing user.
  // Future<UserModel> updateUser(UserModel user) async {
  //   final response = await _supabase
  //       .from('users')
  //       .update(user.toJson())
  //       .eq('id', user.id)
  //       .select()
  //       .single();
  //   return UserModel.fromJson(response);
  // }
}
