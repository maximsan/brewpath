class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
  });

  final String id;
  final String title;
  final String description;

  /// Formatted, localized price string, e.g. `"$2.99"`.
  final String price;

  /// ISO currency code, e.g. `"USD"`.
  final String currencyCode;
}
