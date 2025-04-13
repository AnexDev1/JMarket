// dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentMethodStep extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodStep({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.paymentMethod,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.selectPaymentMethodPrompt,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          // Telebirr button
          _buildPaymentOption(
            context: context,
            isSelected: selectedMethod == 'telebirr',
            title: 'Pay With Telebirr',
            subtitle: '',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.indigo.shade700,
            onTap: () {
              HapticFeedback.selectionClick();
              onMethodSelected('telebirr');
            },
          ),
          // Cbebirr button
          _buildPaymentOption(
            context: context,
            isSelected: selectedMethod == 'cbebirr',
            title: 'Pay with cbebirr',
            subtitle: '',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.indigo.shade700,
            onTap: () {
              HapticFeedback.selectionClick();
              onMethodSelected('cbebirr');
            },
          ),
          // M\-Pesa button
          _buildPaymentOption(
            context: context,
            isSelected: selectedMethod == 'mpesa',
            title: 'Pay with M\-Pesa',
            subtitle: '',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.indigo.shade700,
            onTap: () {
              HapticFeedback.selectionClick();
              onMethodSelected('mpesa');
            },
          ),
          // Ebirr button
          _buildPaymentOption(
            context: context,
            isSelected: selectedMethod == 'ebirr',
            title: 'Pay With Ebirr',
            subtitle: '',
            icon: Icons.account_balance_wallet,
            iconColor: Colors.indigo.shade700,
            onTap: () {
              HapticFeedback.selectionClick();
              onMethodSelected('ebirr');
            },
          ),
          // Cash on Delivery button
          _buildPaymentOption(
            context: context,
            isSelected: selectedMethod == 'cod',
            title: localizations.cashOnDelivery,
            subtitle: localizations.payOnDeliveryDescription,
            icon: Icons.money,
            iconColor: Colors.indigo.shade700,
            onTap: () {
              HapticFeedback.selectionClick();
              onMethodSelected('cod');
            },
          ),
          const SizedBox(height: 24),
          // Secure payment note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock,
                  color: Colors.indigo.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.paymentSecurityMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Colors.indigo.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
