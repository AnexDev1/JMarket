// lib/services/user_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all users.
  Future<List<UserModel>> getAllUsers() async {
    final response = await _supabase.from('users').select('*');
    return (response as List).map((user) => UserModel.fromJson(user)).toList();
  }

  // Get a single user by its ID.
  Future<UserModel> getUserById(String userId) async {
    final response =
        await _supabase.from('users').select('*').eq('id', userId).single();
    return UserModel.fromJson(response);
  }

  // Create a new user.
  Future<UserModel> createUser(UserModel user) async {
    final response =
        await _supabase.from('users').insert(user.toJson()).select().single();
    print(response);
    return UserModel.fromJson(response);
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

  // Delete a user by its ID.
  Future<void> deleteUser(String userId) async {
    await _supabase.from('users').delete().eq('id', userId);
  }
}
