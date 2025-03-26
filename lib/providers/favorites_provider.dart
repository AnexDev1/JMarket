import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  // Getters
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get count => _favoriteIds.length;
  bool get isEmpty => _favoriteIds.isEmpty;

  // Check if a product is in favorites
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  // Add a product to favorites
  void addFavorite(String productId) {
    _favoriteIds.add(productId);
    notifyListeners();
  }

  // Remove a product from favorites
  void removeFavorite(String productId) {
    _favoriteIds.remove(productId);
    notifyListeners();
  }

  // Toggle favorite status
  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  // Clear all favorites
  void clearFavorites() {
    _favoriteIds.clear();
    notifyListeners();
  }
}
