/// Generic search utility for filtering lists
class SearchHelper {
  SearchHelper._();

  /// Generic search function that filters items based on multiple search fields
  ///
  /// [items] - The list of items to search through
  /// [query] - The search query string
  /// [searchFields] - List of functions that extract searchable strings from each item
  ///
  /// Returns filtered list of items matching the query
  static List<T> search<T>({
    required List<T> items,
    required String query,
    required List<String Function(T)> searchFields,
  }) {
    if (query.trim().isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase().trim();

    return items.where((item) {
      return searchFields.any((getFieldValue) {
        final fieldValue = getFieldValue(item);
        return fieldValue.toLowerCase().contains(lowerQuery);
      });
    }).toList();
  }
}
