// File: lib/services/payment_service.dart
import 'package:chapasdk/chapasdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../providers/cart_provider.dart';
import 'order_service.dart';

class PaymentService {
  // This method creates the order after payment/traditional flows.
  Future<void> createOrder({
    required User user,
    required CartProvider cartProvider,
    required String shippingAddress,
    required AppLocalizations localizations,
  }) async {
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

    // Debug: Print the payload for inspection.
    print('Orders payload: \$ordersPayload');

    try {
      final orderService = OrderService();
      final response = await orderService.createOrders(ordersPayload);

      // Debug: Print the response from the order service.
      print('Order creation response: \$response');

      if (response.isNotEmpty) {
        cartProvider.clear();
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(localizations.orderPlacedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!,
          '/orders',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content:
                Text(localizations.errorWithMessage("Failed to create order")),
          ),
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      //   SnackBar(
      //     content: Text(localizations.errorWithMessage(e.toString())),
      //   ),
      // );
    }
  }

  // This method initiates the payment using the Chapa SDK with added logging.
  Future<void> processPayment({
    required BuildContext context,
    required String publicKey,
    required String currency,
    required String amount,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String txRef,
    required String title,
    required String desc,
    required List<String> availablePaymentMethods,
    required String fallbackRoute,
  }) async {
    print('Starting payment process...');
    try {
      await Chapa.paymentParameters(
        context: context,
        publicKey: publicKey,
        currency: currency,
        amount: amount,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        txRef: txRef,
        title: title,
        desc: desc,
        nativeCheckout: true,
        namedRouteFallBack: fallbackRoute,
        showPaymentMethodsOnGridView: false,
        availablePaymentMethods: availablePaymentMethods,
      );
      print('Payment processed successfully.');
    } catch (e) {
      print('Payment error: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
