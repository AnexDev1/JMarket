// lib/providers/orders_provider.dart
import 'package:flutter/foundation.dart';

import '../data/models/order_model.dart';
import '../services/order_service.dart';

class OrdersProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetched;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;

  Future<void> loadOrders(String userId) async {
    // Skip loading if fetched recently (within last 5 minutes)
    if (_orders.isNotEmpty && _lastFetched != null) {
      if (DateTime.now().difference(_lastFetched!).inMinutes < 5) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newOrders = await _orderService.getUserOrders(userId);
      _orders = newOrders;
      _lastFetched = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newOrders = await _orderService.getUserOrders(userId);
      _orders = newOrders;
      _lastFetched = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addOrder(Order newOrder) {
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  void clearOrders() {
    _orders = [];
    _lastFetched = null;
    notifyListeners();
  }
}
