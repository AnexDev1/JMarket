// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';

import '../data/models/user_model.dart';
import '../services/user_service.dart';

// lib/providers/user_provider.dart
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? _user;
  DateTime? _lastFetchTime;
  final int _cacheDuration = 30;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Call this in initState, not during build
  Future<void> fetchUserData(String userId) async {
    if (_user != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < _cacheDuration) {
      return; // Use cached data
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _userService.getUserById(userId);
      _user = userData;
      _lastFetchTime = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void invalidateCache() {
    _user = null;
    _lastFetchTime = null;
    notifyListeners();
  }
}
