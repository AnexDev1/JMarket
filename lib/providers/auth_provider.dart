// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/remote/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  bool _isLoading = true;

  AuthProvider() {
    _initialize();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    _isLoading = true;
    _user = _supabaseService.currentUser;
    _isLoading = false;
    notifyListeners();

    // Listen for auth state changes
    _supabaseService.authStateChanges.listen((event) {
      _user = event.session?.user;
      notifyListeners();
    });
  }

  Future<void> signOut(BuildContext context) async {
    await _supabaseService.client.auth.signOut();
    _user = null;
    notifyListeners();

    // Force router refresh
    if (context.mounted) {
      GoRouter.of(context).refresh();
    }
  }

  // Add convenience methods for authentication
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabaseService.signIn(
      email: email,
      password: password,
    );
    _user = response.user;
    notifyListeners();
    return response;
  }

  Future<AuthResponse> signUp(
      String email, String password, Map<String, dynamic>? userData) async {
    final response = await _supabaseService.signUp(
      email: email,
      password: password,
      userData: userData!,
    );
    _user = response.user;
    notifyListeners();
    return response;
  }

  Future<void> resetPassword(String email) async {
    await _supabaseService.resetPassword(email);
  }
}
