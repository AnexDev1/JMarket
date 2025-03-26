import 'package:flutter/material.dart';

class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final int maxQuantity;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.maxQuantity = 10,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade700;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      quantity > 1 ? Colors.grey.shade50 : Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                ),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: quantity > 1 ? primaryColor : Colors.grey.shade400,
                ),
              ),
            ),
          ),

          // Quantity Display
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Center(
              child: Text(
                quantity.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),

          // Increase Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: quantity < maxQuantity
                  ? () => onQuantityChanged(quantity + 1)
                  : null,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(7),
                bottomRight: Radius.circular(7),
              ),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: quantity < maxQuantity
                      ? Colors.grey.shade50
                      : Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: quantity < maxQuantity
                      ? primaryColor
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
