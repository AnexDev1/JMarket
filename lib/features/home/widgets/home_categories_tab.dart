// lib/features/home/widgets/home_categories_tab.dart
import 'package:flutter/material.dart';

class HomeCategoriesTab extends StatelessWidget {
  final TabController tabController;
  final List<String> categories;

  const HomeCategoriesTab({
    super.key,
    required this.tabController,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.indigo.shade700;

    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 8),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        dividerHeight: 0,
        tabAlignment: TabAlignment.start,
        tabs: categories.map((category) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(category),
            ),
          );
        }).toList(),
        splashBorderRadius: BorderRadius.circular(24),
      ),
    );
  }
}
