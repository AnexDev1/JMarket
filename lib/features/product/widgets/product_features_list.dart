import 'package:flutter/material.dart';

class ProductFeaturesList extends StatelessWidget {
  final List features;

  const ProductFeaturesList({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade700;

    if (features.isEmpty) {
      return Center(
        child: Text(
          'No features available',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                features[index],
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
