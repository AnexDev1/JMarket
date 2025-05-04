import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/product_service.dart';

class ProductsProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final _supabase = Supabase.instance.client;

  // Cache maps category name to products list
  final Map<String, List<Map<String, dynamic>>> _productsCache = {};
  final Map<String, DateTime> _lastFetchTime = {};
  final int _cacheDuration = 15;

  bool _isLoading = false;
  String? _error;
  final Map<String, RealtimeChannel> _subscriptions = {};

  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductsProvider() {
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    final channel = _supabase.channel('public:products');

    // Listen for INSERT events
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'products',
      callback: (payload) {
        final newProduct = payload.newRecord;

        // Update all relevant cached categories
        _productsCache.forEach((category, products) {
          if (category.toLowerCase() == 'all' ||
              category.toLowerCase() ==
                  newProduct['category']?.toString().toLowerCase()) {
            products.add(newProduct);
          }
        });

        Future.microtask(() => notifyListeners());
      },
    );

    // Listen for UPDATE events
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'products',
      callback: (payload) {
        final updatedProduct = payload.newRecord;

        // Update in all categories
        _productsCache.forEach((category, products) {
          final index = products.indexWhere(
              (p) => p['id'].toString() == updatedProduct['id'].toString());
          if (index != -1) {
            products[index] = updatedProduct;
          }
        });

         Future.microtask(() => notifyListeners());
      },
    );

    // Listen for DELETE events
    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'products',
      callback: (payload) {
        final deletedProductId = payload.oldRecord['id'];
        if (deletedProductId != null) {
          // Remove from all categories
          _productsCache.forEach((category, products) {
            products.removeWhere(
                (p) => p['id'].toString() == deletedProductId.toString());
          });

         Future.microtask(() => notifyListeners());
        }
      },
    );

    // Start listening
    channel.subscribe();

    // Store subscription for cleanup later
    _subscriptions['all_changes'] = channel;
  }

  Future<List<Map<String, dynamic>>> getProducts(String category) async {
    // Return cache if fresh
    if (_productsCache.containsKey(category) &&
        _lastFetchTime.containsKey(category)) {
      final lastFetch = _lastFetchTime[category]!;
      if (DateTime.now().difference(lastFetch).inMinutes < _cacheDuration) {
        return _productsCache[category]!;
      }
    }

    // Otherwise fetch fresh data
    return await fetchProducts(category);
  }

Future<List<Map<String, dynamic>>> fetchProducts(String category) async {
  _isLoading = true;
  _error = null;
  // Defer notifying listeners until after the current build frame
  Future.delayed(Duration.zero, () => notifyListeners());

  try {
    final products = await _productService.fetchProducts(category: category);

    // Cache the results
    _productsCache[category] = products;
    _lastFetchTime[category] = DateTime.now();

    if (category.toLowerCase() == 'all') {
      products.shuffle();
    }

    _isLoading = false;
    Future.delayed(Duration.zero, () => notifyListeners());
    return products;
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    Future.delayed(Duration.zero, () => notifyListeners());
    return [];
  }
}

  Future<List<Map<String, dynamic>>> refreshProducts(String category) async {
    return await fetchProducts(category);
  }

  void invalidateCategory(String category) {
    if (_productsCache.containsKey(category)) {
      _productsCache.remove(category);
      _lastFetchTime.remove(category);
      notifyListeners();
    }
  }

  void clearCache() {
    _productsCache.clear();
    _lastFetchTime.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up subscriptions
    _subscriptions.values.forEach((channel) => channel.unsubscribe());
    super.dispose();
  }
}
