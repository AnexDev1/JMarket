// File: lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/order_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all orders for a user.
  Future<List<Order>> getUserOrders(String userId) async {
    final response = await _supabase
        .from('orders')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((order) => Order.fromJson(order)).toList();
  }

  // Get a single order by its ID.
  Future<Order> getOrderById(String orderId) async {
    final response =
        await _supabase.from('orders').select('*').eq('id', orderId).single();
    return Order.fromJson(response);
  }

  Future<List<Order>> createOrders(
      List<Map<String, dynamic>> ordersPayload) async {
    final response =
        await _supabase.from('orders').insert(ordersPayload).select();
    return (response as List).map((order) => Order.fromJson(order)).toList();
  }

  // Update an existing order.
  Future<Order> updateOrder(Order order) async {
    final response = await _supabase
        .from('orders')
        .update(order.toJson())
        .eq('id', order.orderId)
        .select()
        .single();
    return Order.fromJson(response);
  }

  // Delete an order by its ID.
  Future<void> deleteOrder(String orderId) async {
    await _supabase.from('orders').delete().eq('id', orderId);
  }
}
