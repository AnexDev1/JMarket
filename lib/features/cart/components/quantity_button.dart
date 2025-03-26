// lib/features/cart/components/quantity_button.dart
import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const QuantityButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey.shade100 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: onPressed == null
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
