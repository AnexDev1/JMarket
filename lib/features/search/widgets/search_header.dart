// lib/features/search/widgets/search_header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.gray700,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Search field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: AppColors.gray400),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.gray400, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: AppColors.gray400, size: 20),
                        onPressed: onClearSearch,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
            ),
          ),

          // Cancel button
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onClearSearch,
              style: TextButton.styleFrom(
                minimumSize: const Size(60, 40),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: Colors.indigo.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
