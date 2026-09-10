/// The design's durations, so a timing is stated once.
///
/// Mood-independent, like `AppSpacing` — a `static const` on a class with no
/// `of(context)`, so a painter can read one with no `BuildContext`.
abstract final class AppMotion {
  /// The design's `240ms cubic-bezier` opening, rounded to the app's step —
  /// what every accordion, snap and frame move already used separately.
  static const Duration expand = Duration(milliseconds: 320);
}
