// dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/cart_provider.dart';

class CartSummary extends StatelessWidget {
  final CartProvider cartProvider;

  const CartSummary({
    super.key,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final double subtotal = cartProvider.totalPrice;
    final double shipping = subtotal > 100 ? 0.0 : 10.0;
    final double total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryHeader(context),
          const SizedBox(height: 20),
          _buildSummaryRow(context, localizations.subtotal, subtotal),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            localizations.shipping,
            shipping,
            note: shipping == 0 ? localizations.freeShippingOver : null,
          ),
          _buildDivider(),
          _buildSummaryRow(context, localizations.total, total, isTotal: true),
          const SizedBox(height: 24),
          _buildCheckoutButton(context, total),
          _buildPaymentOptions(context),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          localizations.orderSummary,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          localizations.itemsCount(cartProvider.itemCount),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount,
      {bool isTotal = false, String? note}) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.black : Colors.grey.shade700,
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(
                note,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        Text(
          amount == 0
              ? AppLocalizations.of(context)!.free
              : '${amount.toStringAsFixed(2)} ETB',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: amount == 0 && !isTotal ? Colors.green.shade600 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, double total) {
    final localizations = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/checkout');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade700,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          localizations.proceedToCheckout,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizations.securePaymentWith,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              _buildPaymentIcon(Icons.credit_card, Colors.blue.shade700),
              _buildPaymentIcon(Icons.account_balance, Colors.green.shade700),
              _buildPaymentIcon(Icons.payment, Colors.orange.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
