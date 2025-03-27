// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/remote/supabase_service.dart';
import '../data/models/user_model.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final UserService _userService = UserService();
  User? _user;
  UserModel? _extendedUser;
  bool _isLoading = true;

  AuthProvider() {
    _initialize();
  }

  User? get user => _user;
  UserModel? get extendedUser => _extendedUser;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    _isLoading = true;
    _user = _supabaseService.currentUser;
    if (_user != null) {
      await loadUserDetails(_user!.id);
    }
    _isLoading = false;
    notifyListeners();

    // Listen for auth state changes.
    _supabaseService.authStateChanges.listen((event) async {
      _user = event.session?.user;
      if (_user != null) {
        await loadUserDetails(_user!.id);
      } else {
        _extendedUser = null;
      }
      notifyListeners();
    });
  }

  // Load extended user details from the users table.
  Future<void> loadUserDetails(String userId) async {
    try {
      _extendedUser = await _userService.getUserById(userId);
    } catch (e) {
      // Handle error if needed.
      _extendedUser = null;
    }
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    await _supabaseService.client.auth.signOut();
    _user = null;
    _extendedUser = null;
    notifyListeners();

    // Force router refresh.
    if (context.mounted) {
      GoRouter.of(context).refresh();
    }
  }

  // Sign in method
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabaseService.signIn(
      email: email,
      password: password,
    );
    _user = response.user;
    if (_user != null) await loadUserDetails(_user!.id);
    notifyListeners();
    return response;
  }

  Future<AuthResponse> signUp(
      String email, String password, Map<String, dynamic> userData) async {
    final response = await _supabaseService.signUp(
      email: email,
      password: password,
      userData: userData,
    );
    _user = response.user;

    if (_user != null) {
      await _userService.createUser(UserModel(
        id: _user!.id,
        email: email,
        fullName: userData['full_name'],
        phone: userData['phone'],
      ));
      await loadUserDetails(_user!.id);
    }
    notifyListeners();
    return response;
  }

  Future<void> resetPassword(String email) async {
    await _supabaseService.resetPassword(email);
  }
}
