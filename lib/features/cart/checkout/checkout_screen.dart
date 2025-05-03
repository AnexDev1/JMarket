// File: lib/features/cart/checkout/checkout_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:jmarket/widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../providers/cart_provider.dart';
import '../../../services/payment_service.dart';
import '../../../services/user_service.dart';
import 'components/order_confirmation_step.dart';
import 'components/payment_method_step.dart';
import 'components/shipping_details_step.dart';

class TxRefRandomGenerator {
  static String generate({required String prefix, int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final randomPart =
        List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
    return '$prefix$randomPart';
  }
}

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
  String paymentMethod = 'telebirr';

  // User hints
  String? fullNameHint;
  String? phoneHint;

  @override
  void initState() {
    super.initState();
    _loadUserHints();
  }

  final UserService userService = UserService();

  Future<void> _loadUserHints() async {
    final user = await userService.getUserById(userService.currentUser!.id);
    setState(() {
      fullNameHint = user.fullName;
      phoneHint = user.phoneNumber;
    });
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
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
    setState(() {
      paymentMethod = method;
    });
  }

  // Separates the payment process with added logging.
  Future<void> _processPayment(
      double total, String firstName, String lastName) async {
    print('Starting payment process...');
    await PaymentService().processPayment(
      context: context,
      publicKey: dotenv.env['CHAPA_PUBLIC_KEY'] ?? '',
      currency: 'ETB',
      amount: total.toStringAsFixed(2),
      email: Supabase.instance.client.auth.currentUser!.email ??
          'customer@example.com',
      phone: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      txRef: TxRefRandomGenerator.generate(prefix: 'JMarket'),
      title: 'Order Payment',
      desc: 'Payment for order',
      availablePaymentMethods: [paymentMethod],
      fallbackRoute: '/orders',
    );
    print('Payment processed successfully.');
  }

  // Separates the order creation process.
  Future<void> _createOrder() async {
    final localizations = AppLocalizations.of(context)!;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      CustomSnackbar.showFailureSnackBar(context, 'Not Authenticated ',
          '${localizations.userNotAuthenticated}');
      return;
    }
    await PaymentService().createOrder(
      user: user,
      cartProvider: cartProvider,
      shippingAddress: address,
      localizations: localizations,
    );
  }

  Future<void> _placeOrder() async {
    HapticFeedback.mediumImpact();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final supabase = Supabase.instance.client;
    final localizations = AppLocalizations.of(context)!;
    final user = supabase.auth.currentUser;
    if (user == null) {
      CustomSnackbar.showFailureSnackBar(context, 'Not Authenticated ',
          '${localizations.userNotAuthenticated}');
      return;
    }
    if (paymentMethod != 'cod') {
      final subtotal = cartProvider.totalPrice;
      const shipping = 0;
      final tax = 0;
      final total = subtotal + shipping + tax;
      List<String> nameParts = name.split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts[0] : 'Customer';
      String lastName = nameParts.length > 1 ? nameParts.last : '';
      try {
        await _processPayment(total, firstName, lastName);
        await _createOrder();
      } catch (e) {
        CustomSnackbar.showFailureSnackBar(context, 'Payment Failed ',
            '${localizations.errorWithMessage(e.toString())}');
      }
    } else {
      await _createOrder();
    }
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
                ? const Icon(Icons.check, color: Colors.white, size: 18)
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
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ShippingDetailsStep(
                    onNameSaved: (value) => name = value ?? '',
                    onAddressSaved: (value) => address = value ?? '',
                    onCitySaved: (value) => city = value ?? '',
                    onZipCodeSaved: (value) => zipCode = value ?? '',
                    onPhoneNumberSaved: (value) => phoneNumber = value ?? '',
                    fullNameHint: fullNameHint,
                    phoneHint: phoneHint,
                  ),
                  PaymentMethodStep(
                    selectedMethod: paymentMethod,
                    onMethodSelected: _setPaymentMethod,
                  ),
                  OrderConfirmationStep(
                    name: name,
                    address: address,
                    phoneNumber: phoneNumber,
                    paymentMethod: paymentMethod,
                    cartItems: cartProvider.items,
                    subtotal: cartProvider.totalPrice,
                    shipping: 0,
                    tax: 0,
                  ),
                ],
              ),
            ),
          ),
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
                        foregroundColor: Colors.grey.shade700),
                  ),
                const Spacer(),
                if (_currentStep < 2)
                  ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentStep == 0
                          ? localizations.continue_
                          : localizations.reviewOrder,
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
