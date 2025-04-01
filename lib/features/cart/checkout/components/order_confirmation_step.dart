import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:jmarket/data/models/cart_model.dart';

class OrderConfirmationStep extends StatelessWidget {
  final String name;
  final String address;
  final String phoneNumber;
  final String paymentMethod;
  final List<CartItem> cartItems;
  final double subtotal;
  final double shipping;
  final double tax;

  const OrderConfirmationStep({
    super.key,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.cartItems,
    required this.subtotal,
    required this.shipping,
    required this.tax,
  });

  String _getPaymentMethodName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (paymentMethod) {
      case 'cod':
        return localizations.cashOnDelivery;
      case 'chapa':
        return localizations.payWithChapa;
      default:
        return localizations.unknown;
    }
  }

  IconData get _getPaymentMethodIcon {
    switch (paymentMethod) {
      case 'cod':
        return Icons.money;
      case 'chapa':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  Color get _getPaymentMethodColor {
    switch (paymentMethod) {
      case 'cod':
        return Colors.green.shade700;
      case 'chapa':
        return Colors.indigo.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final formatter = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);
    final total = subtotal + shipping + tax;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.orderSummary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 24),

          // Shipping information section
          _buildSectionCard(
            context: context,
            title: localizations.shippingInformation,
            icon: Icons.local_shipping_outlined,
            iconColor: Colors.indigo.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment method section
          _buildSectionCard(
            context: context,
            title: localizations.paymentMethod,
            icon: _getPaymentMethodIcon,
            iconColor: _getPaymentMethodColor,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon,
                    color: _getPaymentMethodColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getPaymentMethodName(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Order items section
          _buildSectionCard(
            context: context,
            title: localizations.orderItems(cartItems.length),
            icon: Icons.shopping_bag_outlined,
            iconColor: Colors.indigo.shade700,
            child: Column(
              children: [
                ...cartItems
                    .map((item) => _buildOrderItem(context, item))
                    .toList(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Price summary section
          _buildSectionCard(
            context: context,
            title: localizations.priceDetails,
            icon: Icons.receipt_long_outlined,
            iconColor: Colors.indigo.shade700,
            child: Column(
              children: [
                _buildPriceRow(context, localizations.subtotal,
                    formatter.format(subtotal)),
                const SizedBox(height: 8),
                _buildPriceRow(context, localizations.shipping,
                    formatter.format(shipping)),
                const SizedBox(height: 8),
                _buildPriceRow(
                    context, localizations.tax, formatter.format(tax)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                _buildPriceRow(
                  context,
                  localizations.total,
                  formatter.format(total),
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Estimated delivery
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.estimatedDelivery,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('EEEE, MMMM d, h:mm a').format(DateTime.now().add(const Duration(minutes: 10)))} - ${DateFormat(' h:mm a').format(DateTime.now().add(const Duration(minutes: 15)))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, CartItem item) {
    final localizations = AppLocalizations.of(context)!;
    final price = item.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl.isNotEmpty
                ? Image.network(
                    item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? localizations.unknownProduct,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.size != null)
                  Text(
                    localizations.size(item.size!),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  localizations.quantity(item.quantity),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(symbol: 'ETB ').format(price),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.grey.shade800 : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.indigo.shade700 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
