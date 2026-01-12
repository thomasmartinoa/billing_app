/// Generic search utility for filtering lists
library;

class SearchHelper {
  SearchHelper._();

  /// Generic search function that filters items based on multiple search fields
  ///
  /// [items] - The list of items to search through
  /// [query] - The search query string
  /// [searchFields] - List of functions that extract searchable strings from each item
  ///
  /// Returns filtered list of items matching the query
  ///
  /// Example:
  /// ```dart
  /// final results = SearchHelper.search(
  ///   items: products,
  ///   query: 'laptop',
  ///   searchFields: [
  ///     (p) => p.name,
  ///     (p) => p.category ?? '',
  ///     (p) => p.sku ?? '',
  ///   ],
  /// );
  /// ```
  static List<T> search<T>({
    required List<T> items,
    required String query,
    required List<String Function(T)> searchFields,
  }) {
    // Return all items if query is empty
    if (query.trim().isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase().trim();

    return items.where((item) {
      // Check if any search field contains the query
      return searchFields.any((getFieldValue) {
        final fieldValue = getFieldValue(item);
        return fieldValue.toLowerCase().contains(lowerQuery);
      });
    }).toList();
  }

  /// Search with custom filter function
  ///
  /// More flexible alternative when you need custom matching logic
  ///
  /// Example:
  /// ```dart
  /// final results = SearchHelper.searchWithFilter(
  ///   items: products,
  ///   query: 'low stock',
  ///   filter: (product, query) {
  ///     if (query == 'low stock') {
  ///       return product.isLowStock;
  ///     }
  ///     return product.name.toLowerCase().contains(query);
  ///   },
  /// );
  /// ```
  static List<T> searchWithFilter<T>({
    required List<T> items,
    required String query,
    required bool Function(T item, String query) filter,
  }) {
    if (query.trim().isEmpty) {
      return items;
    }

    final normalizedQuery = query.toLowerCase().trim();
    return items.where((item) => filter(item, normalizedQuery)).toList();
  }

  /// Fuzzy search with scoring
  ///
  /// Returns items sorted by relevance score
  ///
  /// Example:
  /// ```dart
  /// final results = SearchHelper.fuzzySearch(
  ///   items: products,
  ///   query: 'lptop', // typo in 'laptop'
  ///   searchFields: [
  ///     (p) => p.name,
  ///     (p) => p.category ?? '',
  ///   ],
  /// );
  /// ```
  static List<T> fuzzySearch<T>({
    required List<T> items,
    required String query,
    required List<String Function(T)> searchFields,
    double threshold = 0.5,
  }) {
    if (query.trim().isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase().trim();

    // Calculate relevance score for each item
    final scoredItems = items.map((item) {
      double maxScore = 0.0;

      for (final getFieldValue in searchFields) {
        final fieldValue = getFieldValue(item).toLowerCase();
        final score = _calculateSimilarity(fieldValue, lowerQuery);

        if (score > maxScore) {
          maxScore = score;
        }
      }

      return (item: item, score: maxScore);
    }).where((entry) => entry.score >= threshold).toList();

    // Sort by score (descending)
    scoredItems.sort((a, b) => b.score.compareTo(a.score));

    return scoredItems.map((entry) => entry.item).toList();
  }

  /// Calculate string similarity (simple Levenshtein-based approach)
  static double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Check for substring match (higher score)
    if (s1.contains(s2)) {
      return 0.8 + (s2.length / s1.length) * 0.2;
    }

    // Calculate Levenshtein distance
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    // Convert distance to similarity score (0.0 to 1.0)
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Create distance matrix
    final matrix = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );

    // Initialize first row and column
    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    // Calculate distances
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;

        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Filter items by multiple criteria
  ///
  /// Example:
  /// ```dart
  /// final results = SearchHelper.multiFilter(
  ///   items: products,
  ///   filters: [
  ///     (p) => p.category == 'Electronics',
  ///     (p) => p.sellingPrice < 10000,
  ///     (p) => p.currentStock > 0,
  ///   ],
  /// );
  /// ```
  static List<T> multiFilter<T>({
    required List<T> items,
    required List<bool Function(T)> filters,
  }) {
    return items.where((item) {
      // Item must pass all filters
      return filters.every((filter) => filter(item));
    }).toList();
  }
}
