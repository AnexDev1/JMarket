// lib/providers/search_provider.dart
import 'package:flutter/foundation.dart';
import 'package:jmarket/services/product_service.dart';

class SearchProvider with ChangeNotifier {
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> setSearchQuery(String query) async {
    if (_searchQuery == query) return;

    _searchQuery = query;
    notifyListeners();

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    await searchProducts(query);
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await ProductService().searchProducts(query);
      _searchResults = results;
    } catch (e) {
      print('Error searching products: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
