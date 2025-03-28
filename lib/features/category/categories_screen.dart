// lib/features/category/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final primaryColor = Colors.indigo.shade700;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Replace with actual data fetching
    await Future.delayed(const Duration(milliseconds: 800));

    _categories = [
      {
        'name': 'Electronics',
        'icon': Icons.devices,
        'count': 128,
        'color': Colors.blue
      },
      {
        'name': 'Clothing',
        'icon': Icons.checkroom,
        'count': 96,
        'color': Colors.purple
      },
      {'name': 'Home', 'icon': Icons.home, 'count': 75, 'color': Colors.teal},
      {
        'name': 'Sports',
        'icon': Icons.sports_soccer,
        'count': 64,
        'color': Colors.orange
      },
      {'name': 'Books', 'icon': Icons.book, 'count': 87, 'color': Colors.brown},
      {
        'name': 'Gadgets',
        'icon': Icons.watch,
        'count': 56,
        'color': Colors.red
      },
      {
        'name': 'Furniture',
        'icon': Icons.chair,
        'count': 42,
        'color': Colors.amber
      },
      {'name': 'Beauty', 'icon': Icons.face, 'count': 63, 'color': Colors.pink},
      {'name': 'Toys', 'icon': Icons.toys, 'count': 38, 'color': Colors.green},
      {
        'name': 'Kitchen',
        'icon': Icons.kitchen,
        'count': 45,
        'color': Colors.cyan
      },
      {
        'name': 'Automotive',
        'icon': Icons.car_rental,
        'count': 31,
        'color': Colors.grey
      },
      {
        'name': 'Jewelry',
        'icon': Icons.diamond,
        'count': 27,
        'color': Colors.indigo
      },
    ];

    _filteredCategories = List.from(_categories);
    setState(() => _isLoading = false);
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _categories
          .where((category) => category['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(localizations.categories),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(localizations),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _filteredCategories.isEmpty
                    ? Center(child: Text('No categories found'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(
                                _filteredCategories[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search categories',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey[500]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterCategories('');
                    },
                  )
                : null,
          ),
          onChanged: _filterCategories,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final num height = 100 + (category['count'] * 0.3).clamp(0, 40);

    return Hero(
      tag: 'category-${category['name']}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProductsScreen(
                  category: category,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height.toDouble(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category['color'],
                  category['color'].withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: category['color'].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Icon(
                    category['icon'],
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        category['icon'],
                        color: Colors.white,
                        size: 30,
                      ),
                      const Spacer(),
                      Text(
                        category['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category['count']} products',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
