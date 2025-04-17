import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

class PaymentService {
  Future<void> processPayment({
    required User user,
    required CartProvider cartProvider,
    required String shippingAddress,
    required AppLocalizations localizations,
  }) async {
    // Prepare order payload from cart provider.
    final ordersPayload = cartProvider.items.map((item) {
      return {
        'user_id': user.id,
        'order_id': item.productId,
        'shipping_address': shippingAddress,
        'order_status': 'pending',
        'quantity': item.quantity,
        'created_at': DateTime.now().toIso8601String(),
      };
    }).toList();

    try {
      final orderService = OrderService();
      final response = await orderService.createOrders(ordersPayload);

      if (response.isNotEmpty) {
        // Clear cart upon successful order creation
        cartProvider.clear();

        // Show success message
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(localizations.orderPlacedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Add this navigation to go to orders screen
        // Navigator.pushNamedAndRemoveUntil(
        //   navigatorKey.currentContext!,
        //   '/orders',
        //   (route) => false,
        // );
      } else {
        // Your existing error handling
      }
    } catch (e) {
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(
        SnackBar(content: Text(localizations.errorWithMessage(e.toString()))),
      );
    }
  }
}
