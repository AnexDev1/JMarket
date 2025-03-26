// lib/features/favorites/components/favorites_grid_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'favorites_item_card.dart';

class FavoritesGridView extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteItems;

  const FavoritesGridView({
    super.key,
    required this.favoriteItems,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        // Staggered animation effect
        return AnimatedOpacity(
          duration: Duration(milliseconds: 500 + (index * 100)),
          opacity: 1.0,
          curve: Curves.easeInOut,
          child: AnimatedPadding(
            duration: Duration(milliseconds: 500 + (index * 100)),
            padding: EdgeInsets.zero,
            child: GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                // Add a visual effect for long press if needed
              },
              child: FavoriteItemCard(
                item: favoriteItems[index],
              ),
            ),
          ),
        );
      },
    );
  }
}
