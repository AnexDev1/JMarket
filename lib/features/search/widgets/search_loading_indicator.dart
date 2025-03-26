// lib/features/search/widgets/search_loading_indicator.dart
import 'package:flutter/material.dart';

class SearchLoadingIndicator extends StatelessWidget {
  final String searchQuery;

  const SearchLoadingIndicator({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade700),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Searching for "$searchQuery"...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding the best products for you',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
