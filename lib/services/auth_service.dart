import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client= Supabase.instance.client;

  // Auth methods
  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;


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
}