import 'package:chapa_unofficial/chapa_unofficial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../services/order_service.dart';
import 'components/order_confirmation_step.dart';
import 'components/payment_method_step.dart';
import 'components/shipping_details_step.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form data
  String name = '';
  String address = '';
  String city = '';
  String zipCode = '';
  String phoneNumber = '';
  String paymentMethod = 'cod'; // Default to Cash on Delivery

  void _goToNextStep() {
    if (_currentStep == 0) {
      // Validate shipping form before proceeding
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        HapticFeedback.lightImpact();
        setState(() => _currentStep = 1);
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      // Payment method already selected, proceed to confirmation
      HapticFeedback.lightImpact();
      setState(() => _currentStep = 2);
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _setPaymentMethod(String method) {
    setState(() => paymentMethod = method);
  }

  Future<void> _placeOrder() async {
    final localizations = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    final supabase = Supabase.instance.client;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.userNotAuthenticated)),
      );
      return;
    }

    // If payment method is Chapa, initiate Chapa payment flow
    if (paymentMethod == 'chapa') {
      // Calculate total amount
      final subtotal = cartProvider.totalPrice;
      final shipping = 5.99;
      final tax = subtotal * 0.05;
      final total = subtotal + shipping + tax;

      // Generate a unique transaction reference
      final txRef = TxRefRandomGenerator.generate(prefix: 'JMarket');

      // Split name into first name and last name
      List<String> nameParts = name.split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts[0] : 'Customer';
      String lastName = nameParts.length > 1 ? nameParts.last : '';

      try {
        // Launch Chapa payment
        await Chapa.getInstance.startPayment(
          context: context,
          amount: total.toStringAsFixed(2),
          currency: 'ETB',
          txRef: txRef,
          email: user.email ?? 'customer@example.com',
          firstName: firstName,
          lastName: lastName,
          title: 'Order Payment',
          description: 'Payment for order #$txRef',
          phoneNumber: phoneNumber,
          onInAppPaymentSuccess: (successMsg) async {
            print('Payment successful: $successMsg');
            // Process order after successful payment
            await _processOrderAfterPayment(user, cartProvider, localizations);
            if (context.mounted) {
              context.go('/');
            }
          },
          onInAppPaymentError: (errorMsg) {
            print('Payment error: $errorMsg');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment failed: $errorMsg')),
              );
            }
          },
        );
      } on ChapaException catch (e) {
        String errorMessage = 'Payment error';
        if (e is NetworkException) {
          errorMessage = 'Network error';
        } else if (e is ServerException) {
          errorMessage = 'Server error';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$errorMessage: ${e.toString()}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.errorWithMessage(e.toString()))),
        );
      }
      return;
    }

    // For other payment methods (e.g., COD), proceed with normal order placement
    await _processOrderAfterPayment(user, cartProvider, localizations);
  }

// Helper method to process the order after payment (or for COD)
  Future<void> _processOrderAfterPayment(
    User user,
    CartProvider cartProvider,
    AppLocalizations localizations,
  ) async {
    final shippingAddress = address;
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

    final orderService = OrderService();
    try {
      final response = await orderService.createOrders(ordersPayload);
      if (response.isNotEmpty) {
        // Clear the cart
        cartProvider.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.orderPlacedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          context.go('/');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.orderPlacementFailed),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.errorWithMessage(e.toString()))),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(localizations.checkout),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to home instead of popping
            context.push('/');
          },
        ),
      ),
      body: Column(
        children: [
          // Checkout Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildStepIndicator(
                    isActive: _currentStep >= 0,
                    isDone: _currentStep > 0,
                    title: localizations.shipping,
                    step: 1,
                  ),
                ),
                _buildStepConnector(_currentStep > 0),
                Expanded(
                  child: _buildStepIndicator(
                    isActive: _currentStep >= 1,
                    isDone: _currentStep > 1,
                    title: localizations.payment,
                    step: 2,
                  ),
                ),
                _buildStepConnector(_currentStep > 1),
                Expanded(
                  child: _buildStepIndicator(
                    isActive: _currentStep >= 2,
                    isDone: false,
                    title: localizations.confirm,
                    step: 3,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Main content area with steps
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1: Shipping Details
                  ShippingDetailsStep(
                    onNameSaved: (value) => name = value ?? '',
                    onAddressSaved: (value) => address = value ?? '',
                    onCitySaved: (value) => city = value ?? '',
                    onZipCodeSaved: (value) => zipCode = value ?? '',
                    onPhoneNumberSaved: (value) => phoneNumber = value ?? '',
                  ),

                  // Step 2: Payment Method
                  PaymentMethodStep(
                    selectedMethod: paymentMethod,
                    onMethodSelected: _setPaymentMethod,
                  ),

                  // Step 3: Order Confirmation
                  OrderConfirmationStep(
                    name: name,
                    address: address,
                    phoneNumber: phoneNumber,
                    paymentMethod: paymentMethod,
                    cartItems: cartProvider.items,
                    subtotal: cartProvider.totalPrice,
                    shipping: 5.99,
                    tax: cartProvider.totalPrice * 0.05,
                  ),
                ],
              ),
            ),
          ),

          // Bottom action area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  TextButton.icon(
                    onPressed: _goToPreviousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(localizations.back),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                const Spacer(),
                if (_currentStep < 2)
                  ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(_currentStep == 0
                        ? localizations.continue_
                        : localizations.reviewOrder),
                  )
                else
                  ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(localizations.placeOrder),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required bool isActive,
    required bool isDone,
    required String title,
    required int step,
  }) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? Colors.indigo.shade700
                : isActive
                    ? Colors.indigo.shade100
                    : Colors.grey.shade200,
            border: isDone || isActive
                ? Border.all(color: Colors.indigo.shade700, width: 2)
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive
                          ? Colors.indigo.shade700
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.indigo.shade700 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 30,
      height: 2,
      color: isActive ? Colors.indigo.shade700 : Colors.grey.shade300,
    );
  }
}
