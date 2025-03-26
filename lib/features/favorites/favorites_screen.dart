// lib/features/favorites/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorites_provider.dart';
import 'components/empty_favorites.dart';
import 'components/favorites_grid_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final favoriteItems = favoritesProvider.favoriteItems;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Favorites',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            actions: [
              if (favoriteItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      _showClearFavoritesDialog(context, favoritesProvider),
                ),
            ],
          ),
          body: favoriteItems.isEmpty
              ? const EmptyFavorites()
              : FavoritesGridView(favoriteItems: favoriteItems),
        );
      },
    );
  }

  void _showClearFavoritesDialog(
      BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text('Are you sure you want to remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.clearFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}
