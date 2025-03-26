// lib/features/search/models/trending_search.dart
class TrendingSearch {
  final String term;
  final int count;

  const TrendingSearch({
    required this.term,
    required this.count,
  });

  factory TrendingSearch.fromMap(Map<String, dynamic> map) {
    return TrendingSearch(
      term: map['term'] ?? '',
      count: map['count'] as int,
    );
  }
}
