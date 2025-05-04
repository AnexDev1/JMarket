import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//http
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({Key? key}) : super(key: key);

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
  if (_passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.passwordRequired),
        backgroundColor: Colors.red.shade700,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Verify the user's password before deletion:
    await authProvider.verifyPassword(_passwordController.text);

    // Get the user ID and auth token from Supabase.
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    final authToken = supabase.auth.currentSession?.accessToken;

    if (userId == null || authToken == null) {
      throw Exception('User not authenticated');
    }

    // Call the delete-user-with-orders edge function
    final url = 'https://xhkqzuzzfcjvgvvspsqz.supabase.co/functions/v1/delete-user-with-orders';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      // Sign out the user after deletion.
      await supabase.auth.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.accountDeleted),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/'); // Redirect to login/home screen.
      }
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse['error'] ?? 'Unknown error');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.deleteFailed}: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade700, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.warningLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!
                                    .deleteAccountWarning,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Password verification
                  Text(
                    AppLocalizations.of(context)!.confirmWithPassword,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.enterPasswordToDelete,
                    style: TextStyle(
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _deleteAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.confirmDelete,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
