/// Immutable store product surfaced to the paywall.
class StoreProduct {
  /// Creates a [StoreProduct].
  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.amount,
    required this.currencyCode,
  });

  /// Store product identifier.
  final String id;

  /// Localized product title.
  final String title;

  /// Localized product description.
  final String description;

  /// Formatted, localized price string, e.g. `"$2.99"` — what is shown.
  final String price;

  /// The same price as a number, for comparing two plans.
  ///
  /// Never rendered: a savings claim has to be worked out from the prices the
  /// learner is actually being offered, or it will contradict the rows above
  /// it in a storefront whose ratios differ.
  final double amount;

  /// ISO currency code, e.g. `"USD"`.
  final String currencyCode;
}
