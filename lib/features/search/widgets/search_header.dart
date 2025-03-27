// lib/features/search/widgets/search_header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;
  final Function(String) onSubmitted;
  final VoidCallback onClearSearch;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.onSubmitted,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button that navigates to homepage
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              context.go(AppRoutes.home); // Navigate to homepage
            },
          ),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: onClearSearch,
                          child: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
