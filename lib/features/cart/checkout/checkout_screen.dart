// lib/features/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
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

  void _placeOrder() {
    HapticFeedback.mediumImpact();

    // Process order with collected information
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Here you would send the order to your backend
    // For now, just clear the cart and show success

    // Clear cart
    cartProvider.clear();

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thank you for your order!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive a confirmation soon.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('CONTINUE SHOPPING'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _goToPreviousStep();
            } else {
              // Navigate to home instead of popping
              context.go('/');
            }
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
                    title: 'Shipping',
                    step: 1,
                  ),
                ),
                _buildStepConnector(_currentStep > 0),
                Expanded(
                  child: _buildStepIndicator(
                    isActive: _currentStep >= 1,
                    isDone: _currentStep > 1,
                    title: 'Payment',
                    step: 2,
                  ),
                ),
                _buildStepConnector(_currentStep > 1),
                Expanded(
                  child: _buildStepIndicator(
                    isActive: _currentStep >= 2,
                    isDone: false,
                    title: 'Confirm',
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
                    address: '$address, $city, $zipCode',
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
                    label: const Text('BACK'),
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
                    child:
                        Text(_currentStep == 0 ? 'CONTINUE' : 'REVIEW ORDER'),
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
                    child: const Text('PLACE ORDER'),
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
