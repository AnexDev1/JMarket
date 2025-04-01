// lib/providers/favorites_provider.dart
import 'package:flutter/foundation.dart';
import 'package:jmarket/data/models/product_model.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};
  final List<Product> _favoriteItems = [];

  List<Product> get favoriteItems => _favoriteItems;
  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  void toggleFavorite(Product product) {
    final productId = product.id.toString();

    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      _favoriteItems.removeWhere((item) => item.id.toString() == productId);
    } else {
      _favoriteIds.add(productId);
      _favoriteItems.add(product);
    }
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteItems.clear();
    notifyListeners();
  }

  void removeFavorite(String productId) {
    _favoriteIds.remove(productId);
    _favoriteItems.removeWhere((item) => item.id.toString() == productId);
    notifyListeners();
  }
}
