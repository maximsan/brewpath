/// Immutable store product surfaced to the paywall.
class StoreProduct {
  /// Creates a [StoreProduct].
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
  });

  /// Store product identifier.
  final String id;

  /// Localized product title.
  final String title;

  /// Localized product description.
  final String description;

  /// Formatted, localized price string, e.g. `"$2.99"`.
  final String price;

  /// ISO currency code, e.g. `"USD"`.
  final String currencyCode;
}
