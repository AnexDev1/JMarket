// lib/features/search/widgets/recent_searches_list.dart
import 'package:flutter/material.dart';

class RecentSearchesList extends StatelessWidget {
  final List<String> searches;
  final Function(String) onSearchSelected;
  final Function(String) onSearchRemoved;
  final VoidCallback onClearAll;

  const RecentSearchesList({
    super.key,
    required this.searches,
    required this.onSearchSelected,
    required this.onSearchRemoved,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(10, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searches.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ),
              title: Text(
                searches[index],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => onSearchRemoved(searches[index]),
              ),
              onTap: () => onSearchSelected(searches[index]),
            );
          },
        ),
      ],
    );
  }
}
